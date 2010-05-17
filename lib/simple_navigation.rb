# Load all source files (if this is not done explicitly some naming conflicts may occur if rails app has classes with the same name)
require 'simple_navigation/configuration'
require 'simple_navigation/helpers'
require 'simple_navigation/controller_methods'
require 'simple_navigation/item_adapter'
require 'simple_navigation/item'
require 'simple_navigation/item_container'
require 'simple_navigation/items_provider'
require 'simple_navigation/renderer/base'
require 'simple_navigation/renderer/list'
require 'simple_navigation/renderer/links'
require 'simple_navigation/initializer'
require 'simple_navigation/railtie' if Rails::VERSION::MAJOR == 3

# A plugin for generating a simple navigation. See README for resources on usage instructions.
module SimpleNavigation

  mattr_accessor :config_files, :config_file_path, :default_renderer, :controller, :template, :explicit_current_navigation, :rails_env, :rails_root

  self.config_files = {}
  
  class << self

    def init_rails
      SimpleNavigation.config_file_path = SimpleNavigation.default_config_file_path unless SimpleNavigation.config_file_path
      ActionController::Base.send(:include, SimpleNavigation::ControllerMethods)
    end
  
    def default_config_file_path
      File.join(SimpleNavigation.rails_root, 'config')
    end
  
    def config_file?(navigation_context = :default)
      File.exists?(config_file_name(navigation_context))
    end
  
    # Reads the config_file for the specified navigation_context and stores it for later evaluation.
    def load_config(navigation_context = :default)
      raise "config_file_path is not set!" unless self.config_file_path
      raise "Config file '#{config_file_name(navigation_context)}' does not exists!" unless config_file?(navigation_context)
      if SimpleNavigation.rails_env == 'production'
        self.config_files[navigation_context] ||= IO.read(config_file_name(navigation_context))
      else
        self.config_files[navigation_context] = IO.read(config_file_name(navigation_context))
      end
    end

    def set_template_from(context)
      SimpleNavigation.controller = extract_controller_from context
      SimpleNavigation.template = SimpleNavigation.controller.instance_variable_get(:@template) || (SimpleNavigation.controller.respond_to?(:view_context) ? SimpleNavigation.controller.view_context : nil)
    end

    # Returns the context in which the config file should be evaluated.
    # This is preferably the template, otherwise te controller
    def context_for_eval
      raise 'no context set for evaluation the config file' unless SimpleNavigation.template || SimpleNavigation.controller
      SimpleNavigation.template || SimpleNavigation.controller
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

    # Returns the active item container for the specified level. Valid levels are
    # * :all - in this case the primary_navigation is returned.
    # * a specific level - the active item_container for the specified level will be returned
    # * a range of levels - the active item_container for the range's minimum will be returned
    # 
    # Returns nil if there is no active item_container for the specified level.
    def active_item_container_for(level)
      case level
      when :all
        self.primary_navigation
      when Integer
        self.primary_navigation.active_item_container_for(level)
      when Range
        self.primary_navigation.active_item_container_for(level.min)
      else
        raise ArgumentError, "Invalid navigation level: #{level}"
      end
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

    # Extracts a controller from the context.
    def extract_controller_from(context)
      if context.respond_to? :controller
        context.controller
      else
        context
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
# 0) make sn_set_navigation private in controllers
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
#
# - allow :function navigation item to specify function
# - allow specification of link-options in item (currently options are passed to li-element)
# - render_navigation: do not rescue from config-file not found error if no items are passed in directly
