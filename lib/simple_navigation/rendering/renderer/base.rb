require 'forwardable'

module SimpleNavigation
  module Renderer

    # This is the base class for all renderers.
    #
    # A renderer is responsible for rendering an ItemContainer and its containing items to HTML.
    class Base
      extend Forwardable
            
      attr_reader :options, :adapter
      
      def_delegators :adapter, :link_to, :content_tag
            
      def initialize(options) #:nodoc:
        @options = options
        @adapter = SimpleNavigation.adapter
      end

      def expand_all?
        !!options[:expand_all]
      end

      def level
        options[:level] || :all
      end

      def skip_if_empty?
        !!options[:skip_if_empty]
      end

      def include_sub_navigation?(item)
        consider_sub_navigation?(item) && expand_sub_navigation?(item)
      end

      def render_sub_navigation_for(item)
        item.sub_navigation.render(self.options)
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

      def suppress_link?
        false
      end

      def tag_for(item)
        if item.url.nil? || suppress_link?
          content_tag('span', item.name, link_options_for(item).except(:method))
        else
          link_to(item.name, item.url, link_options_for(item))
        end
      end

      # Extracts the options relevant for the generated link
      #
      def link_options_for(item)
        special_options = {:method => item.method, :class => item.selected_class}.reject {|k, v| v.nil? }
        link_options = item.html_options[:link]
        return special_options unless link_options
        opts = special_options.merge(link_options)
        opts[:class] = [link_options[:class], item.selected_class].flatten.compact.join(' ')
        opts.delete(:class) if opts[:class].nil? || opts[:class] == ''
        opts
      end            
    end
  end
end
