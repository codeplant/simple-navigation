# Load all source files (if this is not done explicitly some naming conflicts may occur if rails app has classes with the same name)
require 'simple_navigation/configuration'
require 'simple_navigation/helpers'
require 'simple_navigation/controller_methods'
require 'simple_navigation/item'
require 'simple_navigation/item_container'
require 'simple_navigation/renderer/base'
require 'simple_navigation/renderer/list'

# A plugin for generating a simple navigation. See README for resources on usage instructions.
module SimpleNavigation

  mattr_accessor :config_files, :config_file_path, :controller, :template
  self.config_files = {}
  
  class << self
  
    # Reads the config_file for the specified navigation_context and stores it for later evaluation.
    def load_config(navigation_context = :default)
      raise "config_file_path is not set!" unless self.config_file_path
      raise "Config file '#{config_file_name(navigation_context)}' does not exists!" unless File.exists?(config_file_name(navigation_context))
      if ::RAILS_ENV == 'production'
        self.config_files[navigation_context] ||= IO.read(config_file_name(navigation_context))
      else
        self.config_files[navigation_context] = IO.read(config_file_name(navigation_context))
      end
    end

    # Returns the singleton instance of the SimpleNavigation::Configuration
    def config 
      Configuration.instance
    end
  
    # Returns the ItemContainer that contains the items for the primary navigation
    def primary_navigation
      config.primary_navigation
    end

    # Returns the path to the config_file for the given navigation_context
    def config_file_name(navigation_context = :default)
      file_name = navigation_context == :default ? '' : "#{navigation_context.to_s.underscore}_"
      File.join(config_file_path, "#{file_name}navigation.rb")
    end

    # Reads the current navigation for the specified level from the controller.
    # Returns nil if there is no current navigation set for level.
    def current_navigation_for(level)
      self.controller.instance_variable_get(:"@sn_current_navigation_#{level}")
    end

    def active_item_container_for(level)
      self.primary_navigation.active_item_container_for(level)
    end


  end

end