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
    
    it 'should pass long environment vars' do
      shell = DaptivChefCI::Shell.new()
      out = shell.exec_cmd('echo $ENV_VAR1', 600, { 'ENV_VAR1' => 'val1' })
      expect(out[0]).to eq('val1')
    end
    
    it 'should convert environment symbol keys to strings' do
      shell = DaptivChefCI::Shell.new()
      out = shell.exec_cmd('echo $ENV_VAR1', 600, { :ENV_VAR1 => 'val1' })
      expect(out[0]).to eq('val1')
    end

    it 'should default LC_ALL environment var to nil' do
      shell = DaptivChefCI::Shell.new()
      out = shell.exec_cmd('echo $LC_ALL', 600)
      expect(out[0]).to be nil
    end

    it 'should allow override of LC_ALL environment var' do
      shell = DaptivChefCI::Shell.new()
      out = shell.exec_cmd('echo $LC_ALL', 600, { :LC_ALL => 'en_US.UTF-8' })
      expect(out[0]).to eq('en_US.UTF-8')
    end
    
  end
  
  describe 'path_without_gem_dir' do
    
    it 'should not be prefixed by the system gem dir' do
      shell = DaptivChefCI::Shell.new()
      path = shell.path_without_gem_dir()
      expect(path).not_to include(Bundler.bundle_path.to_s() + ':')
      expect(ENV['PATH']).to include(path)
    end
    
  end
  
end
