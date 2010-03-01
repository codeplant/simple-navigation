ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'spec'
require 'active_support'
require 'action_controller'

module Rails
  module VERSION
    MAJOR = 2
  end
end unless defined? Rails

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'simple_navigation'

SimpleNavigation.rails_root = './'

# Spec::Runner.configure do |config|
  # no special config
# endx