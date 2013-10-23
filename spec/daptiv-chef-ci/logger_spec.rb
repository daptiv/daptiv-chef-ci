require 'mocha/api'
require 'daptiv-chef-ci/logger'
require 'log4r'

describe DaptivChefCI::Logger, :unit => true do

  describe 'init' do
    
    # get logging level before running any of these tests
    before(:all) do
      @chef_ci_log = ENV['CHEF_CI_LOG']
    end
    
    # reset logging back to starting state before this fixture
    after(:all) do
      ENV['CHEF_CI_LOG'] = @chef_ci_log
      DaptivChefCI::Logger.init()
    end
    
    # reset logging back to default state before every test
    before(:each) do
      ENV['CHEF_CI_LOG'] = ''
      DaptivChefCI::Logger.init()
    end
    
    it 'should initialize logging to info by default' do
      DaptivChefCI::Logger.init()
      logger = Log4r::Logger.new("daptiv_chef_ci::logger_spec")
      expect(logger.level).to eq(2)
    end
    
    it 'should initialize logging to the specified level' do
      ENV['CHEF_CI_LOG'] = 'DEBUG'
      DaptivChefCI::Logger.init()
      logger = Log4r::Logger.new("daptiv_chef_ci::logger_spec")
      expect(logger.level).to eq(1)
    end
    
  end

end
