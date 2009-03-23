module SimpleNavigation
  module Renderer
    
    # This is the base class for all renderers.
    #
    # A renderer is responsible for rendering an ItemContainer (primary or a sub_navigation) and its containing items to HTML.
    # It must be initialized with the current_navigation for the rendered ItemContainer and 
    # optionally with the current_sub_navigation (if the sub_navigation will be nested).
    class Base
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper
      
      attr_reader :current_navigation, :current_sub_navigation
      
      def initialize(current_navigation, current_sub_navigation=nil) #:nodoc:
        @current_navigation = current_navigation
        @current_sub_navigation = current_sub_navigation
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