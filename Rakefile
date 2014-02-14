require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rdoc/task'

desc 'Default: run specs.'
task :default => :spec

desc 'Run the specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['--colour --format progress']
end

namespace :spec do
  desc "Run all specs with RCov"
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rspec_opts = ['--colour --format progress']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec,/Users/']
  end
end

desc 'Generate documentation for the simple_navigation plugin.'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SimpleNavigation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
