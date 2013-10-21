module DaptivChefCI
  class Logger

    # Initializes and enables logging to the given environments level
    # By default logging only occurs at ERROR level or higher.
    # Set CHEF_CI_LOG env var to change logging levels
    def self.init()
      require 'log4r'
      
      # Set the logging level on all "chef-ci" namespaced
      # logs as long as we have a valid level.
      logger = Log4r::Logger.new("daptiv_chef_ci")
      logger.outputters = Log4r::Outputter.stderr
      logger.level = log_level()
      logger = nil
    end
    
    # LogLevels = ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL']
    # DEBUG = 1
    # INFO = 2
    # WARN = 3
    # ERROR = 4
    # FATAL = 5
    def self.log_level()
      level = ENV['CHEF_CI_LOG'].upcase().to_s()
      level_i = Log4r::Log4rConfig::LogLevels.index(level)
      level_i + 1
    rescue
      return 4 # error
    end
    
  end
end