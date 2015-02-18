require 'rake'
require 'rake/tasklib'
require 'rake/dsl_definition'
require 'json'
require 'tempfile'
require_relative 'raketask_helper'
require_relative 'shell'

class CloneEnvironment
  # Example usage, copies a Chef environment definition to another
  # environment.
  #
  # CloneEnvironment::RakeTask.new do |t|
  #   t.src_env = 'dev'
  #   t.dest_env = "vagrant-#{ENV['LOGNAME']}-dotnetframework"
  # end
  #
  # This class lets you define Rake tasks to clone Chef environments.
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    include DaptivChefCI::RakeTaskHelpers

    attr_accessor :src_env
    attr_accessor :dest_env

    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    def initialize(name = 'clone_environment', desc = 'Clone environment task')
      @logger = Log4r::Logger.new('daptiv_chef_ci::clone_environment_task')
      @shell = DaptivChefCI::Shell.new
      @name, @desc = name, desc
      yield self if block_given?
      define_task
    end

    private

    def define_task
      desc @desc
      task @name do
        execute do
          fail 'src_env must be specified' unless @src_env
          fail 'dest_env must be specified' unless @dest_env
          clone_environment
        end
      end
    end

    def clone_environment
      out = @shell.exec_cmd_in_context(
        "knife environment show #{@src_env} -F json").join(' ')

      env = JSON.parse(out)
      env['name'] = @dest_env
      env['description'] = "The #{dest_env} environment"

      env_file = Tempfile.new([@dest_env, '.json'])
      begin
        IO.write(env_file.path, JSON.pretty_generate(env))

        @shell.exec_cmd_in_context(
          "knife environment from file '#{env_file.path}'")
      ensure
        env_file.close
        env_file.unlink
      end
    end
  end
end
