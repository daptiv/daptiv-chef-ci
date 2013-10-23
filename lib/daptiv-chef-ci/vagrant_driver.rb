require 'log4r'
require 'socket'
require 'erubis'
require 'tempfile'
require_relative 'shell'

module DaptivChefCI
  class VagrantDriver
    
    # Constructs a new Vagrant management instance
    #
    # @param [Shell] The CLI
    # @param [Hash] The options to pass to the Vagrantfile
    #
    # options[:guest_os] - defaults to :linux
    # options[:chef_repo_dir] - The chef-repo root directory, defaults to ~/src/chef-repo
    # options[:box_name] - defaults to 'Vagrant-hostname'
    # options[:node_name] - The chef node name, defaults to 'Vagrant-hostname'
    # options[:box_url] - URL to the box download location, this is optional.
    # options[:run_list] - The Chef run list, defaults to empty.
    # options[:chef_json] - Any additional Chef attributes in json format.
    def initialize(shell, options)
      @logger = Log4r::Logger.new("daptiv_chef_ci::vagrant")
      @shell = shell
      
      options[:guest_os] ||= :linux
      options[:box_name] ||= "Vagrant-#{Socket.gethostname}"
      options[:box_url] ||= nil
      options[:node_name] ||= options[:box_name]
      options[:run_list] ||= []
      options[:chef_repo_dir] = "#{ENV['HOME']}/src/chef-repo"
      options[:chef_json] ||= nil
      @options = options
    end
    
    def backup_vagrantfile()
      if File.exists?('Vagrantfile')
        @vagrantfile_bak = Tempfile.new('Vagrantfile')
        @vagrantfile_bak.write(File.read('Vagrantfile'))
        @vagrantfile_bak.close()
      end
    end
    
    def restore_vagrantfile()
      if @vagrantfile_bak
        @vagrantfile_bak.open()
        IO.write('Vagrantfile', @vagrantfile_bak.read())
        @vagrantfile_bak.unlink()
      end
    end
    
    def create_vagrantfile()
      @logger.debug('Creating Vagrantfile')
      File.open('Vagrantfile', 'w') do |f|
        f.write render_vagrantfile()
      end
    end
    
    def render_vagrantfile()
      Erubis::Eruby.new(vagrantfile_erb()).result(@options)
    end
    
    def destroy()
      @shell.exec_cmd('vagrant destroy -f')
    end
    
    def halt()
      @shell.exec_cmd('vagrant halt')
    end
    
    def up()
      @shell.exec_cmd('vagrant up')
    end
    
    def provision()
      @shell.exec_cmd('vagrant provision')
    end
    
    def reload()
      @shell.exec_cmd('vagrant reload')
    end
    
    
    private
    
    def vagrantfile_erb()
      path = vagrantfile_erb_path()
      @logger.info("Using #{path} to render Vangrantfile")
      File.read(vagrantfile_erb_path())
    end
    
    def vagrantfile_erb_path()
      erbs = [
        File.join(Dir.pwd, 'Vagrantfile.erb'),
        File.join(Dir.pwd, 'Vagrantfile'),
        File.expand_path('Vagrantfile.erb', template_dir())
      ]
          
      erbs.each do |erb|
        @logger.debug("Searching for #{erb}")
        return erb if File.exists?(erb)
      end
      # This should never happen
      raise 'Couldn\'t find a Vagrantfile.erb!'
    end
    
    def template_dir()
      File.join(File.expand_path(File.dirname(__FILE__)), 'templates')
    end
    
  end
end