require File.dirname(__FILE__) + '/../../../spec_helper'
require 'html/document' unless defined? HTML::Document

describe SimpleNavigation::Renderer::Links do
    
  describe 'render' do
    

    def render(current_nav=nil, options={:level => :all})
      primary_navigation = primary_container
      select_item(current_nav) if current_nav
      @renderer = SimpleNavigation::Renderer::Links.new(options)
      HTML::Document.new(@renderer.render(primary_navigation)).root
    end
      
    context 'regarding result' do
      
      it "should render a div-tag around the items" do
        HTML::Selector.new('div').select(render).should have(1).entries
      end
      it "the rendered div-tag should have the specified dom_id" do
        HTML::Selector.new('div#nav_dom_id').select(render).should have(1).entries
      end
      it "the rendered div-tag should have the specified class" do
        HTML::Selector.new('div.nav_dom_class').select(render).should have(1).entries
      end
      it "should render an a-tag for each item" do
        HTML::Selector.new('a').select(render).should have(3).entries
      end
      it "should pass the specified html_options to the a element" do
        HTML::Selector.new('a[style=float:right]').select(render).should have(1).entries
      end
      it "should give the a-tag the id specified in the html_options" do
        HTML::Selector.new('a#my_id').select(render).should have(1).entries
      end
      it "should give the a-tag the default id (stringified key) if no id is specified in the html_options" do
        HTML::Selector.new('a#invoices').select(render).should have(1).entries
      end
      it "should not apply the the default id where there is an id specified in the html_options" do
        HTML::Selector.new('a#users').select(render).should be_empty
      end
    
      context 'with current_navigation set' do
        it "should mark the matching a-item as selected (with the css_class specified in configuration)" do
          HTML::Selector.new('a.selected').select(render(:invoices)).should have(1).entries
        end      
      end
    
      context 'without current_navigation set' do
        it "should not mark any of the items as selected" do
          HTML::Selector.new('a.selected').select(render).should be_empty
        end
      end
    
      # context 'nested sub_navigation' do
      #   it "should nest the current_primary's subnavigation inside the selected li-element" do
      #     HTML::Selector.new('li.selected ul li').select(render(:invoices)).should have(2).entries
      #   end
      #   it "should be possible to identify sub items using an html selector (using ids)" do
      #     HTML::Selector.new('#invoices #subnav1').select(render(:invoices)).should have(1).entries
      #   end
      #   context 'expand_all => false' do
      #     it "should not render the invoices submenu if the user-primary is active" do
      #       HTML::Selector.new('#invoices #subnav1').select(render(:users, :level => :all, :expand_all => false)).should be_empty
      #       HTML::Selector.new('#invoices #subnav2').select(render(:users, :level => :all, :expand_all => false)).should be_empty
      #     end
      #   end
      # 
      #   context 'expand_all => true' do
      #     it "should render the invoices submenu even if the user-primary is active" do
      #       HTML::Selector.new('#invoices #subnav1').select(render(:users, :level => :all, :expand_all => true)).should have(1).entry
      #       HTML::Selector.new('#invoices #subnav2').select(render(:users, :level => :all, :expand_all => true)).should have(1).entry
      #     end
      #   end
      #     
      # end
    end
    
    context 'regarding method calls' do
      
      context 'regarding the div_content' do
        before(:each) do
          @primary_navigation = primary_container
          @div_content = stub(:div_content)
          @div_items = stub(:div_items, :join => @div_content)
          @items.stub!(:inject => @div_items)
          @renderer = SimpleNavigation::Renderer::Links.new(options)
        end
      
        it "should join the list_items" do
          @div_items.should_receive(:join)
        end
      
        it "should html_saferize the list_content" do
          @renderer.should_receive(:html_safe).with(@div_content)
        end
      
        after(:each) do
          @renderer.render(@primary_navigation)
        end
      end
      
      context 'regarding the items' do
        before(:each) do
          @primary_navigation = primary_container
          @renderer = SimpleNavigation::Renderer::Links.new(options)
        end
        
        it "should call html_safe on every item's name" do
          @items.each do |item|
            @renderer.should_receive(:html_safe).with(item.name)
          end
          @renderer.should_receive(:html_safe).with(anything)
          @renderer.render(@primary_navigation)
        end
      end
      
    end
    
  end
end