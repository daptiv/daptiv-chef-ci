require 'rake'
require 'rake/tasklib'
require 'rake/dsl_definition'
require_relative 'raketask_helper'

class VersionCookbook
  # Example usage, versions a cookbook to 1.0.x for usage in CI
  #
  # VersionCookbook::RakeTask.new 'version_cookbook' do |t|
  #   t.bump = false
  #   t.version = "1.0.#{ENV['BUILD_NUMBER']}"
  #   t.version_file = 'version.txt'
  # end
  #
  # This class lets you define Rake tasks to manage a cookbook
  # version.txt file
  class RakeTask < ::Rake::TaskLib
    include ::Rake::DSL if defined? ::Rake::DSL
    include DaptivChefCI::RakeTaskHelpers

    attr_accessor :bump
    attr_accessor :version
    attr_accessor :version_file

    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    def initialize(name = 'version_cookbook', desc = 'Version cookbook task')
      @logger = Log4r::Logger.new('daptiv_chef_ci::version_cookbook_task')
      @name, @desc = name, desc
      @version_file = File.join(Dir.pwd, 'version.txt')
      @bump = true
      yield self if block_given?
      define_task
    end

    private

    def define_task
      desc @desc
      task @name do
        execute do
          create_or_update_version_file
        end
      end
    end

    def create_or_update_version_file
      version = Versionomy.parse(start_version)
      version = version.bump(:tiny) if @bump
      write_version(version)
    end

    def start_version
      raw_version = @version
      if !raw_version && File.exist?(@version_file)
        raw_version = IO.read(@version_file).chomp
      end
      raw_version = '0.0.1' unless raw_version
      @logger.debug("Found starting cookbook version: #{raw_version}")
      raw_version
    end

    def write_version(version)
      @logger.debug("Setting cookbook version: #{version}")
      IO.write(@version_file, version.to_s)
    end
  end
end
