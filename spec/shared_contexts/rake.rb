require 'rake'
require 'daptiv-chef-ci/raketask_helper'

shared_context 'rake' do
  let(:rake)           { create_rake_application }
  let(:vagrant_driver) { stub }

  # let the errors bubble up normally, don't exit the app
  before { DaptivChefCI::RakeTaskHelpers.exit_on_failure = false }

  def create_rake_application
    Rake.application = Rake::Application.new
    subject.vagrant_driver = vagrant_driver
    Rake::Task.define_task(subject)
    Rake.application
  end
end
