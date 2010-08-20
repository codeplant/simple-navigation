require 'active_support'
require 'simple_navigation/core'
require 'simple_navigation/rendering'
require 'simple_navigation/adapters'

# A plugin for generating a simple navigation. See README for resources on usage instructions.
module SimpleNavigation

  mattr_accessor :adapter_class, :adapter, :config_files, :config_file_paths, :default_renderer, :registered_renderers, :root, :environment

  self.config_files = {}
  self.registered_renderers = {
    :list         => SimpleNavigation::Renderer::List,
    :links        => SimpleNavigation::Renderer::Links,
    :breadcrumbs  => SimpleNavigation::Renderer::Breadcrumbs
  }

  class << self
    delegate :request, :request_uri, :request_path, :context_for_eval, :current_page?, :to => :adapter
    delegate :init_framework, :to => :adapter_class

    def framework
      return :rails if defined?(Rails)
      return :sinatra if defined?(Sinatra)
      return :padrino if defined?(Padrino)
      raise 'simple_navigation currently only works for Rails, Sinatra and Padrino apps'
    end

    def choose_adapter
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

    # Reads the config_file for the specified navigation_context and stores it for later evaluation.
    def load_config(navigation_context = :default)
      raise "Config file for #{navigation_context} context not found in #{config_file_paths_sentence}!" unless config_file?(navigation_context)      
      if SimpleNavigation.rails_env == 'production'
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

    # Returns the path to the config_file for the given navigation_context
    def config_file_name(navigation_context = :default)
      file_name = navigation_context == :default ? '' : "#{navigation_context.to_s.underscore}_"
      File.join(config_file_path, "#{file_name}navigation.rb")
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
