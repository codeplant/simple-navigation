module SimpleNavigation
  module Renderer
    class Base
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper
      
      attr_reader :current_navigation, :current_sub_navigation
      def initialize(current_navigation, current_sub_navigation=nil)
        @current_navigation = current_navigation
        @current_sub_navigation = current_sub_navigation
      end
    end
  end
end