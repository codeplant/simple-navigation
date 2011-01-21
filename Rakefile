require 'rake'
require 'rspec/core/rake_task'
require 'rake/rdoctask'

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

desc 'Generate documentation for the simple_navigation_ext plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SimpleNavigationExt'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "simple-navigation-ext"
    gemspec.summary = "simple-navigation-ext is an extension of andi schacke's library and add the feature to explicitly exclude urls from highlighting."
    gemspec.email = "info@screenconcept.ch"
    gemspec.homepage = "https://github.com/screenconcept/simple-navigation"
    gemspec.description = "simple-navigation-ext is an extension of andi schacke's library and add the feature to explicitly exclude urls from highlighting."
    gemspec.add_development_dependency('rspec', '>= 2.0.1')
    gemspec.add_dependency('activesupport', '>= 2.3.2')
    gemspec.authors = ["Marco"]
    gemspec.rdoc_options = ["--inline-source", "--charset=UTF-8"]
    gemspec.files = FileList["[A-Z]*", "{lib,spec,rails,generators}/**/*"] - FileList["**/*.log"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError => e
  puts "Jeweler not available (#{e}). Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
