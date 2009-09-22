require File.dirname(__FILE__) + '/../../../spec_helper'
require 'html/document' unless defined? HTML::Document

describe SimpleNavigation::Renderer::List do
    
  describe 'render' do
    
    def sub_items
      [
        [:subnav1, 'subnav1', 'subnav1_url', {}, nil],
        [:subnav2, 'subnav2', 'subnav2_url', {}, nil]
      ]
    end
    
    def primary_items
      [
        [:users, 'users', 'first_url', {:id => 'my_id'}, nil],
        [:invoices, 'invoices', 'second_url', {}, nil],
        [:accounts, 'accounts', 'third_url', {:style => 'float:right'}, nil]
      ]
    end

    def primary_container
      container = SimpleNavigation::ItemContainer.new(0)
      container.dom_id = 'nav_dom_id'
      container.dom_class = 'nav_dom_class'
      @items = primary_items.map {|params| SimpleNavigation::Item.new(container, *params)}
      @items.each {|i| i.stub!(:selected? => false)}
      container.instance_variable_set(:@items, @items)
      primary_item(:invoices) {|item| item.instance_variable_set(:@sub_navigation, subnav_container)}
      container
    end

    def primary_item(key)
      yield @items.find {|i| i.key == key}
    end

    def select_item(key)
      primary_item(key) {|item| item.stub!(:selected? => true)}
    end

    def subnav_container
      container = SimpleNavigation::ItemContainer.new(1)
      items = sub_items.map {|params| SimpleNavigation::Item.new(container, *params)}
      items.each {|i| i.stub!(:selected? => false)}
      container.instance_variable_set(:@items, items)
      container
    end

    def render(current_nav=nil, include_subnav=false)
      primary_navigation = primary_container
      select_item(current_nav) if current_nav
      @renderer = SimpleNavigation::Renderer::List.new
      HTML::Document.new(@renderer.render(primary_navigation, include_subnav)).root
    end
      
    it "should render a ul-tag around the items" do
      HTML::Selector.new('ul').select(render).should have(1).entries
    end
    it "the rendered ul-tag should have the specified dom_id" do
      HTML::Selector.new('ul#nav_dom_id').select(render).should have(1).entries
    end
    it "the rendered ul-tag should have the specified class" do
      HTML::Selector.new('ul.nav_dom_class').select(render).should have(1).entries
    end
    it "should render a li tag for each item" do
      HTML::Selector.new('li').select(render).should have(3).entries
    end
    it "should render an a-tag inside each li-tag" do
      HTML::Selector.new('li a').select(render).should have(3).entries
    end
    it "should pass the specified html_options to the li element" do
      HTML::Selector.new('li[style=float:right]').select(render).should have(1).entries
    end
    it "should give the li the id specified in the html_options" do
      HTML::Selector.new('li#my_id').select(render).should have(1).entries
    end
    it "should give the li the default id (stringified key) if no id is specified in the html_options" do
      HTML::Selector.new('ul li#invoices').select(render).should have(1).entries
    end
    it "should not apply the the default id where there is an id specified in the html_options" do
      HTML::Selector.new('ul li#users').select(render).should be_empty
    end
    
    context 'with current_navigation set' do
      it "should mark the matching li-item as selected (with the css_class specified in configuration)" do
        HTML::Selector.new('li.selected').select(render(:invoices)).should have(1).entries
      end
      it "should also mark the links inside the selected li's as selected" do
        HTML::Selector.new('li.selected a.selected').select(render(:invoices)).should have(1).entries
      end
      
    end
    
    context 'without current_navigation set' do
      it "should not mark any of the items as selected" do
        HTML::Selector.new('li.selected').select(render).should be_empty
      end
      it "should not mark any links as selected" do
        HTML::Selector.new('a.selected').select(render).should be_empty
      end
    end
    
    context 'nested sub_navigation' do
      it "should nest the current_primary's subnavigation inside the selected li-element" do
        HTML::Selector.new('li.selected ul li').select(render(:invoices, true)).should have(2).entries
      end
      it "should be possible to identify sub items using an html selector (using ids)" do
        HTML::Selector.new('#invoices #subnav1').select(render(:invoices, true)).should have(1).entries
      end
      context 'render_all_levels = false' do
        before(:each) do
          SimpleNavigation.config.render_all_levels = false
        end
        it "should not render the invoices submenu if the user-primary is active" do
          HTML::Selector.new('#invoices #subnav1').select(render(:users, true)).should be_empty
          HTML::Selector.new('#invoices #subnav2').select(render(:users, true)).should be_empty
        end
      end
      
      context 'render_all_levels = true' do
        before(:each) do
          SimpleNavigation.config.render_all_levels = true
        end
        it "should render the invoices submenu even if the user-primary is active" do
          HTML::Selector.new('#invoices #subnav1').select(render(:users, true)).should have(1).entry
          HTML::Selector.new('#invoices #subnav2').select(render(:users, true)).should have(1).entry
        end
      end
      
    end
    
  end
end