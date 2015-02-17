require 'rake'
require 'rake/tasklib'
require 'rake/dsl_definition'
require_relative 'raketask_helper'
require_relative 'shell'

class UploadCookbook
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

    attr_accessor :environment
    attr_accessor :freeze

    # @param [String] name The task name.
    # @param [String] desc Description of the task.
    def initialize(name = 'upload_cookbook', desc = 'Upload cookbook task')
      @logger = Log4r::Logger.new('daptiv_chef_ci::upload_cookbook_task')
      @shell = DaptivChefCI::Shell.new
      @name, @desc = name, desc
      @freeze = false
      yield self if block_given?
      define_task
    end

    private

    def define_task
      desc @desc
      task @name do
        execute do
          upload_cookbook
        end
      end
    end

    def upload_cookbook
      cmd = "knife cookbook upload #{cookbook_name} -o ../"
      cmd << " -E #{environment}" if @environment
      @shell.exec_cmd_in_context(cmd)
    end

    def cookbook_name
      unless @cookbook_name
        metadata = IO.read(File.join(Dir.pwd, 'metadata.rb'))
        @cookbook_name = /name\s+['|"](\w+)/.match(metadata)[1]
        fail 'Cannot find cookbook name in metadata.rb' unless @cookbook_name
        @logger.debug("found cookbook name: #{@cookbook_name}")
      end
      @cookbook_name
    end
  end
end
