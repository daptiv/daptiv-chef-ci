# Daptiv Chef CI
Common tools to help automate Vagrant in CI

This is a really thin wrapper around Vagrant that makes it a little easier to call Vagrant from a Rake build. Why on earth does this exist?

1. Makes it easier to call your installed Vagrant from a Rake build.
2. Ensures vagrant is loaded from your PATH and _not_ from a bundled gem.

## Basic Usage

Add a dependency for daptiv-chef-ci in your Gemfile

`gem 'daptiv-chef-ci'`

In your Rakefile require 'daptiv-chef-ci/vagrant_task' and then declare a new Vagrant::RakeTask. The minimal task declaration look like this in your rake file:

```
require 'daptiv-chef-ci/vagrant_task'

Vagrant::RakeTask.new
```

## Logging

To change the gem logging level set the CHEF_CI_LOG environment variable to one supported by log4r (DEBUG, INFO etc).

`CHEF_CI_LOG=DEBUG bundle exec rake vagrant`

## Development

Clone this repository and use [Bundler](http://gembundler.com) to get the dependencies:

```
$ bundle install
```

Once you have the dependencies, you can run the unit tests with `rake`:

```
$ bundle exec rake
```

If those pass, you're ready to start developing.
