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

desc 'Generate documentation for the simple_navigation plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SimpleNavigation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "simple-navigation"
    gemspec.summary = "simple-navigation is a ruby library for creating navigations (with multiple levels) for your Rails2, Rails3, Sinatra or Padrino application."
    gemspec.email = "andreas.schacke@gmail.com"
    gemspec.homepage = "http://github.com/andi/simple-navigation"
    gemspec.description = "With the simple-navigation gem installed you can easily create multilevel navigations for your Rails, Sinatra or Padrino applications. The navigation is defined in a single configuration file. It supports automatic as well as explicit highlighting of the currently active navigation through regular expressions."
    gemspec.add_development_dependency('rspec', '>= 2.0.1')
    gemspec.add_dependency('activesupport', '>= 2.3.2')
    gemspec.authors = ["Andi Schacke"]
    gemspec.rdoc_options = ["--inline-source", "--charset=UTF-8"]
    gemspec.files = FileList["[A-Z]*", "{lib,spec,rails,generators}/**/*"] - FileList["**/*.log"]
    gemspec.rubyforge_project = 'andi'
  end
  Jeweler::GemcutterTasks.new
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError => e
  puts "Jeweler not available (#{e}). Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
