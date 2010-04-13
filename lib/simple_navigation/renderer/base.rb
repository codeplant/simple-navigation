module SimpleNavigation
  module Renderer
    
    # This is the base class for all renderers.
    #
    # A renderer is responsible for rendering an ItemContainer and its containing items to HTML.
    class Base
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper
      
      attr_reader :controller, :options

      class << self
        
        # Delegates method calls to the controller.
        def controller_method(*methods)
          methods.each do |method|
            delegate method, :to => :controller
          end
        end
        
      end

      controller_method :form_authenticity_token, :protect_against_forgery?, :request_forgery_protection_token
      
      def initialize(options) #:nodoc:
        @options = options
        @controller = SimpleNavigation.controller
      end
            
      def expand_all?
        !!options[:expand_all]
      end
      
      def level
        options[:level] || :all
      end      
      
      def include_sub_navigation?(item)
        consider_sub_navigation?(item) && expand_sub_navigation?(item)
      end      
      
      def render_sub_navigation_for(item)
        item.sub_navigation.render(self.options)
      end
      
      # Marks the specified input as html_safe (for Rails3). Does nothing if html_safe is not defined on input. 
      #
      def html_safe(input)
        input.respond_to?(:html_safe) ? input.html_safe : input
      end
                  
      # Renders the specified ItemContainer to HTML.
      #
      # When implementing a renderer, please consider to call include_sub_navigation? to determin
      # whether an item's sub_navigation should be rendered or not.
      #  
      def render(item_container)
        raise 'subclass responsibility'
      end
         
      protected
      
      def consider_sub_navigation?(item)
        return false if item.sub_navigation.nil?
        case level
        when :all
          return true
        when Integer
          return false
        when Range
          return item.sub_navigation.level <= level.max
        end
        false
      end
      
      def expand_sub_navigation?(item)
        expand_all? || item.selected?
      end
      
            
    end
  end
end