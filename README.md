# Daptiv Chef CI
Common tools to help automate Vagrant in CI

This is a really thin wrapper around Vagrant that makes it a little easier to call Vagrant from a Rake build. Why on earth does this exist?

1. Makes it easier to call your installed Vagrant from a Rake build.
2. Ensures vagrant is loaded from your PATH and _not_ from a bundled gem.
3. Reduces duplication between cookbook Vagrantfiles.

# Basic Usage

Add a dependency for daptiv-chef-ci in your Gemfile

`gem 'daptiv-chef-ci'`

In your Rakefile require 'daptiv-chef-ci/vagrant_task' and then declare a new Vagrant::RakeTask with your project's Vagrant configuration. Here's an example that specifies a Windows Vagrant box:

```
require 'daptiv-chef-ci/vagrant_task'

Vagrant::RakeTask.new do |task|
  task.guest_os = :windows
  task.box_name = 'vagrant-windows2008r2'
  task.box_url = 'http://example.com/vagrant/boxes/vagrant-windows2008r2.box'
  task.run_list = ['mycookbook::recipe']
end
```

# Configuration

The vagrant task makes the following assumptions:

- guest_os - defaults to :linux
- chef_repo_dir - The chef-repo root directory, defaults to ~/src/chef-repo
- box_name - defaults to 'Vagrant-hostname', this is optional.
- node_name - The chef node name, defaults to 'Vagrant-hostname', this is optional.
- box_url - URL to the box download location, this is optional.
- run_list - The Chef run list, defaults to empty.
- chef_json - Any additional Chef attributes in json format, this is optional.

# Development

Clone this repository and use [Bundler](http://gembundler.com) to get the dependencies:

```
$ bundle install
```

Once you have the dependencies, you can run the unit tests with `rake`:

```
$ bundle exec rake
```

If those pass, you're ready to start developing.
