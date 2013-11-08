require "rake"

shared_context "rake" do
  let(:rake)           { create_rake_application() }
  let(:vagrant_driver) { stub() }
  
  def create_rake_application
    Rake.application = Rake::Application.new
    subject.vagrant_driver = vagrant_driver
    Rake::Task.define_task(subject)
    Rake.application
  end
end