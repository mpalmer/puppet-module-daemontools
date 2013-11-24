require 'rake'
require 'rspec/core/rake_task'

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |t|
	t.pattern = 'spec/*/*_spec.rb'
end

task :spec => "librarian:install"

namespace :librarian do
	desc "Install all dependencies specified in Puppetfile"
	task :install do
		sh "librarian-puppet install --path spec/fixtures/modules"
	end
	
	desc "Update all dependencies to their latest versions"
	task :update do
		sh "librarian-puppet update"
	end
end

desc "Run guard"
task :guard do
	require 'guard'
	::Guard.start(:clear => true, :debug => true)
	while ::Guard.running do
		sleep 0.5
	end
end
