require 'singleton'

module SimpleNavigation
  
  # Responsible for evaluating and handling the config/navigation.rb file. 
  class Configuration
    include Singleton
    
    attr_accessor :renderer
    attr_accessor :selected_class
    attr_accessor :render_all_levels
    attr_accessor :autogenerate_item_ids
    attr_reader :primary_navigation

    class << self

      # Evals the config_file for the given navigation_context inside the specified context (usually a controller or view)
      def eval_config(context, navigation_context = :default)
        context.instance_eval(SimpleNavigation.config_files[navigation_context])
        SimpleNavigation.controller = extract_controller_from context
      end

      # Starts processing the configuration
      def run(&block)
        block.call Configuration.instance
      end    

      # Extracts a controller from the context.
      def extract_controller_from(context)
        if context.respond_to? :controller
          context.controller
        else
          context
        end
      end

    end
    
    # Sets the config's default-settings
    def initialize
      @renderer = SimpleNavigation::Renderer::List
      @selected_class = 'selected'
      @render_all_levels = false
      @autogenerate_item_ids = true
    end
  
    # Yields an SimpleNavigation::ItemContainer for adding navigation items
    def items(&block)
      @primary_navigation = ItemContainer.new
      block.call @primary_navigation
    end
    
    # Returns true if the config_file has already been evaluated.
    def loaded?
      !@primary_navigation.nil?
    end    
    
  end  
  
end