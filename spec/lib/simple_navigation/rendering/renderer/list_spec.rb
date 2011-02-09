require 'spec_helper'
require 'html/document' unless defined? HTML::Document

describe SimpleNavigation::Renderer::List do

  describe 'render' do

    def render(current_nav=nil, options={:level => :all})
      primary_navigation = primary_container
      select_item(current_nav) if current_nav
      setup_renderer_for SimpleNavigation::Renderer::List, :rails, options
      HTML::Document.new(@renderer.render(primary_navigation)).root
    end

    context 'regarding result' do

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

      context 'concerning item names' do
        context 'with a custom name generator defined' do
          before(:each) do
            SimpleNavigation.config.name_generator = Proc.new {|name| "<span>name</span>"}
          end
          it "should apply the name generator" do
            HTML::Selector.new('li a span').select(render).should have(3).entries
          end
        end
        context 'no customer generator defined' do
          before(:each) do
            SimpleNavigation.config.name_generator = Proc.new {|name| "name"}
          end
          it "should apply the name generator" do
            HTML::Selector.new('li a span').select(render).should have(0).entries
          end
        end
      end

      context 'concerning html attributes' do
        context 'default case (no options defined for link tag)' do
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
        end
        context 'with attributes defined for the link tag as well' do
          it "should add the link attributes to the link" do
            HTML::Selector.new('a[style=float:left]').select(render).should have(1).entries
          end
          it "should add the li attributes to the li element" do
            HTML::Selector.new('li[style=float:right]').select(render).should have(1).entries
          end
          it "should give the li the default id (stringified key) if no id is specified in the html_options for the li-element" do
            HTML::Selector.new('ul li#invoices').select(render).should have(1).entries
          end
          it "should not apply the the default id where there is an id specified in the html_options for th li-element" do
            HTML::Selector.new('ul li#users').select(render).should be_empty
          end
        end
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
          HTML::Selector.new('li.selected ul li').select(render(:invoices)).should have(2).entries
        end
        it "should be possible to identify sub items using an html selector (using ids)" do
          HTML::Selector.new('#invoices #subnav1').select(render(:invoices)).should have(1).entries
        end
        context 'expand_all => false' do
          it "should not render the invoices submenu if the user-primary is active" do
            HTML::Selector.new('#invoices #subnav1').select(render(:users, :level => :all, :expand_all => false)).should be_empty
            HTML::Selector.new('#invoices #subnav2').select(render(:users, :level => :all, :expand_all => false)).should be_empty
          end
        end

        context 'expand_all => true' do
          it "should render the invoices submenu even if the user-primary is active" do
            HTML::Selector.new('#invoices #subnav1').select(render(:users, :level => :all, :expand_all => true)).should have(1).entry
            HTML::Selector.new('#invoices #subnav2').select(render(:users, :level => :all, :expand_all => true)).should have(1).entry
          end
        end

      end

      context 'skip_if_empty' do

        def render_container(options={})
          setup_renderer_for SimpleNavigation::Renderer::List, :rails, options
          HTML::Document.new(@renderer.render(@container)).root
        end

        context 'container is empty' do
          before(:each) do
            @container = SimpleNavigation::ItemContainer.new(0)
          end
          context 'skip_if_empty is true' do
            it "should not render a ul tag for the empty container" do
              HTML::Selector.new('ul').select(render_container(:skip_if_empty => true)).should be_empty
            end
          end
          context 'skip_if_empty is false' do
            it "should render a ul tag for the empty container" do
              HTML::Selector.new('ul').select(render_container(:skip_if_empty => false)).should have(1).entry
            end
          end
        end

        context 'container is not empty' do
          before(:each) do
            @container = primary_container
          end
          context 'skip_if_empty is true' do
            it "should render a ul tag for the container" do
              HTML::Selector.new('ul').select(render_container(:skip_if_empty => true)).should have(1).entry
            end
          end
          context 'skip_if_empty is false' do
            it "should render a ul tag for the container" do
              HTML::Selector.new('ul').select(render_container(:skip_if_empty => false)).should have(1).entry
            end
          end
        end
      end
    end
    
    describe 'link_options_for' do
      before(:each) do
        setup_renderer_for SimpleNavigation::Renderer::List, :rails, {}
      end
      context 'no link options specified' do
        context 'method specified' do
          context 'item selected' do
            before(:each) do
              @item = stub(:item, :method => :delete, :selected_class => 'selected', :html_options => {})
            end
            it {@renderer.send(:link_options_for, @item).should == {:method => :delete, :class => 'selected'}}
          end
          context 'item not selected' do
            before(:each) do
              @item = stub(:item, :method => :delete, :selected_class => nil, :html_options => {})
            end
            it {@renderer.send(:link_options_for, @item).should == {:method => :delete}}
          end
        end
        context 'method not specified' do
          context 'item selected' do
            before(:each) do
              @item = stub(:item, :method => nil, :selected_class => 'selected', :html_options => {})
            end
            it {@renderer.send(:link_options_for, @item).should == {:class => 'selected'}}
          end
          context 'item not selected' do
            before(:each) do
              @item = stub(:item, :method => nil, :selected_class => nil, :html_options => {})
            end
            it {@renderer.send(:link_options_for, @item).should == {}}
          end        
        end
      end
      context 'link options specified' do
        before(:each) do
          @item = stub(:item, :method => :delete, :selected_class => 'selected', :html_options => {:link => {:class => 'link_class', :style => 'float:left'}})
        end
        it {@renderer.send(:link_options_for, @item).should == {:method => :delete, :class => 'link_class selected', :style => 'float:left'}}
      end
    end
    
  end
end
