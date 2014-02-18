require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rdoc/task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SimpleNavigation'
  rdoc.options << '--inline-source'
  rdoc.rdoc_files.include('README.md', 'lib/**/*.rb')
end
