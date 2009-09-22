module SimpleNavigation
  module Renderer
    
    # This is the base class for all renderers.
    #
    # A renderer is responsible for rendering an ItemContainer (primary or a sub_navigation) and its containing items to HTML.
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
      def render(item_container, include_sub_navigation=false)
        raise 'subclass responsibility'
      end
            
    end
  end
end