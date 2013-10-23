require 'mocha/api'
require 'daptiv-chef-ci/virtualbox_driver'
require 'daptiv-chef-ci/logger'
require 'mixlib/shellout/exceptions'
require 'bundler'

describe DaptivChefCI::Shell, :unit => true do

  describe 'exec_cmd' do
    
    it 'should split output by line' do
      shell = DaptivChefCI::Shell.new()
      out = shell.exec_cmd('ls -l')
      expect(out.count).to be > 1
    end
    
    it 'should raise exception if exit status is non-zero' do
      shell = DaptivChefCI::Shell.new()
      expect { shell.exec_cmd('rm') }.to raise_error(Mixlib::ShellOut::ShellCommandFailed)
    end
    
    it 'should revert path when method returns' do
      path_before = ENV['PATH']
      shell = DaptivChefCI::Shell.new()
      shell.exec_cmd('ls -l')
      expect(ENV['PATH']).to eq(path_before)
    end
    
  end
  
  describe 'path_without_gem_dir' do
    
    it 'should not be prefixed by the system gem dir' do
      shell = DaptivChefCI::Shell.new()
      path = shell.path_without_gem_dir()
      expect(path).not_to include(Bundler.bundle_path.to_s())
      expect(ENV['PATH']).to include(path)
    end
    
  end
  
end
