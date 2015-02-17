require 'log4r'
require 'bundler'
require 'mixlib/shellout'

module DaptivChefCI
  # Command shell wrapper
  class Shell
    def initialize
      @logger = Log4r::Logger.new('daptiv_chef_ci::shell')
    end

    # Executes the specified shell command and returns the stdout.
    #
    # This method ensure that any invoked command use the same PATH environment
    # that the user has outside Ruby/Bundler.
    #
    # @param [String] The command line to execute
    # @param [Int] The number of seconds to wait for the command to finish,
    # defaults to 600
    # @param [Hash] Key value pairs of environment variables to pass to the
    # command's environment.
    # @return [Array] Each entry represents a line from the stdout
    def exec_cmd(command, timeout = nil, environment = {})
      timeout ||= 600
      environment = Hash[ environment.map{ |k, v| [k.to_s, v.to_s] } ]
      environment['LC_ALL'] = ENV['LC_ALL'] unless environment.key?('LC_ALL')
      path_at_start = ENV['PATH']
      begin
        ENV['PATH'] = path_without_gem_dir
        @logger.debug("Temporarily setting PATH: #{ENV['PATH']}")
        @logger.info("Executing: '#{command}'")
        @logger.debug("\n\ttimeout: #{timeout}\n\tenvironment: #{environment}")

        shell_out = Mixlib::ShellOut.new(
          command, timeout: timeout, environment: environment)
        shell_out.live_stream = STDOUT

        shell_out.run_command
        shell_out.invalid! if shell_out.exitstatus != 0
        @logger.info(shell_out.stdout)
        shell_out.stdout.split("\n")
      ensure
        @logger.debug("Resetting PATH: #{path_at_start}")
        ENV['PATH'] = path_at_start
      end
    end

    # Returns the PATH environment variable as it was before Bundler prepended
    # the system gem directory to it.
    #
    # This can happen if the user has invoked "require 'bundler/setup'"
    # somewhere, like in this gems Rakefile.
    #
    # This is needed because sometimes a user will have the Vagrant gem
    # installed on their system and we don't want to use it, we should use the
    # one that's in their PATH as if they invoked vagrant themselves
    # (i.e. the installed version)
    #
    # @return [String] The ENV['PATH] without the Bundler system gem dir
    # prepended
    def path_without_gem_dir
      paths = ENV['PATH'].split(':')
      system_gem_dir = "#{Bundler.bundle_path}/bin"
      @logger.debug("System gem dir: #{system_gem_dir}")
      paths.delete_if { |p| p.downcase == system_gem_dir.downcase }
      paths.join(':')
    end
  end
end
