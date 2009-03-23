# TODO this is only needed for testing since we do not load the RAILS_ENV... may be require these in the spec_helper?
require 'simple_navigation/configuration'
require 'simple_navigation/helpers'
require 'simple_navigation/controller_methods'
require 'simple_navigation/item'
require 'simple_navigation/item_container'
require 'simple_navigation/renderer/base'
require 'simple_navigation/renderer/list'

# A plugin for generating a simple navigation. See README for usage instructions.
module SimpleNavigation

  mattr_accessor :config_file
  
  # Reads the specified config_file and stores it for later evaluation.
  def self.load_config(config_file)
    self.config_file = IO.read(config_file)
  end

  # Returns the singleton instance of the SimpleNavigation::Configuration
  def self.config 
    Configuration.instance
  end
  
  # Returns the ItemContainer that contains the items for the primary navigation
  def self.primary_navigation
    config.primary_navigation
  end

end