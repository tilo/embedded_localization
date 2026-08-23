# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Run spec with coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
  `open coverage/index.html`
end
