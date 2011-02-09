require 'singleton'

module SimpleNavigation

  # Responsible for evaluating and handling the config/navigation.rb file.
  class Configuration
    include Singleton

    attr_accessor :renderer, :selected_class, :autogenerate_item_ids, :id_generator, :auto_highlight, :name_generator
    attr_reader :primary_navigation

    class << self

      # Evals the config_file for the given navigation_context
      def eval_config(navigation_context = :default)
        SimpleNavigation.context_for_eval.instance_eval(SimpleNavigation.config_files[navigation_context])
      end

      # Starts processing the configuration
      def run(&block)
        block.call Configuration.instance
      end

    end #class << self

    # Sets the config's default-settings
    def initialize
      @renderer = SimpleNavigation.default_renderer || SimpleNavigation::Renderer::List
      @selected_class = 'selected'
      @autogenerate_item_ids = true
      @id_generator = Proc.new {|id| id.to_s }
      @name_generator = Proc.new {|name| name}
      @auto_highlight = true
    end

    # This is the main method for specifying the navigation items. It can be used in two ways:
    #
    # 1. Declaratively specify your items in the config/navigation.rb file using a block. It then yields an SimpleNavigation::ItemContainer for adding navigation items.
    # 1. Directly provide your items to the method (e.g. when loading your items from the database).
    #
    # ==== Example for block style (configuration file)
    #   config.items do |primary|
    #     primary.item :my_item, 'My item', my_item_path
    #     ...
    #   end
    #
    # ==== To consider when directly providing items
    # items_provider should be:
    # * a methodname (as symbol) that returns your items. The method needs to be available in the view (i.e. a helper method)
    # * an object that responds to :items
    # * an enumerable containing your items
    # The items you specify have to fullfill certain requirements. See SimpleNavigation::ItemAdapter for more details.
    #
    def items(items_provider=nil, &block)
      raise 'please specify either items_provider or block, but not both' if (items_provider && block) || (items_provider.nil? && block.nil?)
      @primary_navigation = ItemContainer.new
      if block
        block.call @primary_navigation
      else
        @primary_navigation.items = SimpleNavigation::ItemsProvider.new(items_provider).items
      end
    end

    # Returns true if the config_file has already been evaluated.
    def loaded?
      !@primary_navigation.nil?
    end    
        
  end  
  
end