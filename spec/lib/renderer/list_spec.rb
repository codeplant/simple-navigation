require File.dirname(__FILE__) + '/../../spec_helper'
require 'html/document' unless defined? HTML::Document

describe SimpleNavigation::Renderer::List do
    
  describe 'render' do
    
    def sub_items
      [
        SimpleNavigation::Item.new(:subnav1, 'subnav1', 'subnav1_url', {}, nil),
        SimpleNavigation::Item.new(:subnav2, 'subnav2', 'subnav2_url', {}, nil)
      ]
    end
    
    def primary_items
      @item1 = SimpleNavigation::Item.new(:users, 'users', 'first_url', {:id => 'my_id'}, nil)
      @item2 = SimpleNavigation::Item.new(:invoices, 'invoices', 'second_url', {}, nil)
      @item3 = SimpleNavigation::Item.new(:accounts, 'accounts', 'third_url', {:style => 'float:right'}, nil)
      @item2.instance_variable_set(:@sub_navigation, item_container(sub_items))
      [@item1, @item2, @item3]
    end

    def item_container(items)
      container = SimpleNavigation::ItemContainer.new
      container.dom_id = 'nav_dom_id'
      container.instance_variable_set(:@items, items)
      container
    end

    def primary_navigation
      @item_container = item_container(primary_items)
      @item_container
    end

    def render(current_navigation=nil, include_subnav=false)
      @renderer = SimpleNavigation::Renderer::List.new(current_navigation)
      HTML::Document.new(@renderer.render(primary_navigation, include_subnav)).root
    end
      
    it "should render a ul-tag around the items" do
      HTML::Selector.new('ul').select(render).should have(1).entries
    end
    it "the rendered ul-tag should have the specified dom_id" do
      HTML::Selector.new('ul#nav_dom_id').select(render).should have(1).entries
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
    end
    
  end
end