require "bundler/gem_tasks"

require 'rubygems'
require 'rake'

require 'rspec/core/rake_task'

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

desc "Run specs for all test cases"
task :spec_all do
  system "rake spec"
end

task :default => :spec

desc 'Run spec with coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
  `open coverage/index.html`
end
