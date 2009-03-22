require 'singleton'

module SimpleNavigation
  
  # Responsible for evaluating and handling the config/navigation.rb file. 
  class Configuration
    include Singleton
    
    attr_accessor :renderer
    attr_accessor :selected_class
    attr_reader :primary_navigation

    # Evals the config_file inside the specified context (usually a controller or view)
    def self.eval_config(context)
      context.instance_eval(SimpleNavigation.config_file)
    end

    # Starts processing the configuration
    def self.run(&block)
      block.call Configuration.instance
    end    
    
    # Sets the config's default-settings
    def initialize
      @renderer = SimpleNavigation::Renderer::List
      @selected_class = 'selected'
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