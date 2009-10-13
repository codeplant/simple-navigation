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

  mattr_accessor :config_files, :config_file_path, :controller, :template, :explicit_current_navigation

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
      SimpleNavigation::Configuration.instance
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

    def explicit_navigation_args
      self.controller.instance_variable_get(:"@sn_current_navigation_args")
    end

    # Reads the current navigation for the specified level from the controller.
    # Returns nil if there is no current navigation set for level.
    def current_navigation_for(level)
      self.controller.instance_variable_get(:"@sn_current_navigation_#{level}")
    end

    def active_item_container_for(level)
      self.primary_navigation.active_item_container_for(level)
    end
    
    # If any navigation has been explicitely set in the controller this method evaluates the specified args set in the controller and sets
    # the correct instance variable in the controller.
    def handle_explicit_navigation
      if SimpleNavigation.explicit_navigation_args
        begin
          level, navigation = parse_explicit_navigation_args
          self.controller.instance_variable_set(:"@sn_current_navigation_#{level}", navigation)
        rescue
          #we do nothing here
          #TODO: check if this is the right way to handle wrong explicit navigation
        end
      end
    end

    private
  
    # TODO: refactor this ugly thing to make it nice and short
    def parse_explicit_navigation_args
      args = SimpleNavigation.explicit_navigation_args
      args = [Hash.new] if args.empty?
      if args.first.kind_of? Hash
        options = args.first
      else # args is a list of current navigation for several levels
        options = {}
        if args.size == 1 #only an navi-key has been specified, try to find out level
          level = SimpleNavigation.primary_navigation.level_for_item(args.first)
          options[:"level_#{level}"] = args.first if level
        else
          args.each_with_index {|arg, i| options[:"level_#{i + 1}"] = arg}
        end
      end
      #only the deepest level is relevant
      level = options.inject(0) do |max, kv|
        kv.first.to_s =~ /level_(\d)/
        max = $1.to_i if $1.to_i > max
        max
      end
      raise ArgumentError, "Invalid level specified or item key not found" if level == 0
      [level, options[:"level_#{level}"]]
    end

  end

end

# TODOs for the next releases:
# 1) add ability to specify explicit highlighting in the config-file itself (directly with the item)
#    - item.highlight_on :controller => 'users', :action => 'show' ...^
#   --> with that we can get rid of the controller_methods...
#
# 2) ability to turn off autohighlighting for a single item... 
# 
# 3) add JoinRenderer (HorizontalRenderer?) (wich does not render a list, but just the items joined with a specified char (e.g. | ))
#
# 4) Enhance SampleProject (more examples)
#
# 5) Make SampleProject public
