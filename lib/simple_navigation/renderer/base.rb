module SimpleNavigation
  module Renderer
    
    # This is the base class for all renderers.
    #
    # A renderer is responsible for rendering an ItemContainer and its containing items to HTML.
    class Base
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper
      
      attr_reader :controller

      class << self
        
        # Delegates method calls to the controller.
        def controller_method(*methods)
          methods.each do |method|
            delegate method, :to => :controller
          end
        end
        
      end

      controller_method :form_authenticity_token, :protect_against_forgery?, :request_forgery_protection_token
      
      def initialize #:nodoc:
        @controller = SimpleNavigation.controller
      end
            
      # Renders the specified ItemContainer to HTML.
      #
      # If <tt>include_sub_navigation</tt> is set to true, the renderer should nest the sub_navigation for the active navigation 
      # inside that navigation item.
      #
      # A renderer should also take the option SimpleNavigation.config.render_all_levels into account. If it is set to true then it should render all navigation levels
      # independent of the <tt>include_sub_navigation</tt> option.
      #  
      def render(item_container, include_sub_navigation=false)
        raise 'subclass responsibility'
      end
            
    end
  end
end