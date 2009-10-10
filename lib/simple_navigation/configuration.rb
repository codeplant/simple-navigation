require 'singleton'

module SimpleNavigation
  
  # Responsible for evaluating and handling the config/navigation.rb file. 
  class Configuration
    include Singleton
    
    attr_accessor :renderer, :selected_class, :render_all_levels, :autogenerate_item_ids, :auto_highlight
    attr_reader :primary_navigation

    class << self

      # Evals the config_file for the given navigation_context inside the specified context (usually a controller or view)
      def eval_config(context, navigation_context = :default)
        SimpleNavigation.controller = extract_controller_from context
        SimpleNavigation.template = SimpleNavigation.controller.instance_variable_get(:@template)
        context_for_eval.instance_eval(SimpleNavigation.config_files[navigation_context])
      end
      
      # Starts processing the configuration
      def run(&block)
        block.call Configuration.instance
      end    

      # Returns the context in which the config file should be evaluated.
      # This is preferably the template, otherwise te controller
      def context_for_eval
        raise 'no context set for evaluation the config file' unless SimpleNavigation.template || SimpleNavigation.controller
        SimpleNavigation.template || SimpleNavigation.controller
      end

      # Extracts a controller from the context.
      def extract_controller_from(context)
        if context.respond_to? :controller
          context.controller
        else
          context
        end
      end
      
    end #class << self
    
    # Sets the config's default-settings
    def initialize
      @renderer = SimpleNavigation::Renderer::List
      @selected_class = 'selected'
      @render_all_levels = false
      @autogenerate_item_ids = true
      @auto_highlight = true
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