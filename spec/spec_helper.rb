ENV["RAILS_ENV"] = "test"
RAILS_ENV = "test" unless defined? RAILS_ENV
require 'rubygems'
require 'spec'
require 'active_support'
require 'action_controller'

RAILS_ROOT = './' unless defined? RAILS_ROOT

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'simple_navigation'

# Spec::Runner.configure do |config|
  # no special config
# endx