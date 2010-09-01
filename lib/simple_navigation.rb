require 'simple_navigation/core'
require 'simple_navigation/rendering'
require 'simple_navigation/adapters'
require 'forwardable'

# A plugin for generating a simple navigation. See README for resources on usage instructions.
module SimpleNavigation
  
  
  mattr_accessor :adapter_class, :adapter, :config_files, :config_file_paths, :default_renderer, :registered_renderers, :root, :environment

  self.config_files = {}
  self.config_file_paths = []
  self.registered_renderers = {
    :list         => SimpleNavigation::Renderer::List,
    :links        => SimpleNavigation::Renderer::Links,
    :breadcrumbs  => SimpleNavigation::Renderer::Breadcrumbs
  }
  
  class << self
    extend Forwardable
    
    def_delegators :adapter, :request, :request_uri, :request_path, :context_for_eval, :current_page?
    def_delegators :adapter_class, :register

    # Sets the root path and current environment as specified. Also sets the default config_file_path.
    def set_env(root, environment)
      self.root = root
      self.environment = environment
      self.config_file_paths << SimpleNavigation.default_config_file_path
    end

    # Returns the current framework in which the plugin is running.
    def framework
      return :rails if defined?(Rails)
      return :padrino if defined?(Padrino)
      return :sinatra if defined?(Sinatra)
      raise 'simple_navigation currently only works for Rails, Sinatra and Padrino apps'
    end
    
    # Loads the adapter for the current framework
    def load_adapter
      self.adapter_class = case framework
      when :rails
        SimpleNavigation::Adapters::Rails
      when :sinatra
        SimpleNavigation::Adapters::Sinatra
      when :padrino
        SimpleNavigation::Adapters::Padrino
      end
    end

    def init_adapter_from(context)
      self.adapter = self.adapter_class.new(context)
    end
  
    def default_config_file_path
      File.join(SimpleNavigation.root, 'config')
    end

    # Returns true if the config_file for specified context does exist.
    def config_file?(navigation_context = :default)
      !!config_file(navigation_context)
    end

    # Returns the config file for the given navigation context or nil if no matching config file can be found.
    # If multiple config_paths are set, it returns the first matching file.
    #
    def config_file(navigation_context = :default)
      config_file_paths.collect { |path| File.join(path, config_file_name(navigation_context)) }.detect {|full_path| File.exists?(full_path)}
    end

    # Returns the name of the config file for the given navigation_context
    def config_file_name(navigation_context = :default)
      prefix = navigation_context == :default ? '' : "#{navigation_context.to_s.underscore}_"
      "#{prefix}navigation.rb"      
    end
    
    # Sets the config_file_path
    def config_file_path=(path)
      self.config_file_paths = [path]
    end

    # Reads the config_file for the specified navigation_context and stores it for later evaluation.
    def load_config(navigation_context = :default)
      raise "Config file '#{config_file_name(navigation_context)}' not found in path(s) #{config_file_paths.join(', ')}!" unless config_file?(navigation_context)      
      if self.environment == 'production'
        self.config_files[navigation_context] ||= IO.read(config_file(navigation_context))
      else
        self.config_files[navigation_context] = IO.read(config_file(navigation_context))
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
        
    # Registers a renderer.
    #
    # === Example
    # To register your own renderer:
    #
    #   SimpleNavigation.register_renderer :my_renderer => My::RendererClass
    #
    # Then in the view you can call:
    #
    #   render_navigation(:renderer => :my_renderer)
    #
    def register_renderer(renderer_hash)
      self.registered_renderers.merge!(renderer_hash)
    end

  end

end

SimpleNavigation.choose_adapter

# TODOs for the next releases:

# - add JoinRenderer (HorizontalRenderer?) (wich does not render a list, but just the items joined with a specified char (e.g. | ))
# - allow :function navigation item to specify function
# - allow specification of link-options in item (currently options are passed to li-element)
# - render_navigation: do not rescue from config-file not found error if no items are passed in directly
