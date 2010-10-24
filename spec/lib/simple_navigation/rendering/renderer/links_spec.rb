require 'spec_helper'
require 'html/document' unless defined? HTML::Document

describe SimpleNavigation::Renderer::Links do

    
  describe 'render' do

    def render(current_nav=nil, options={:level => :all})
      primary_navigation = primary_container
      select_item(current_nav) if current_nav
      setup_renderer_for SimpleNavigation::Renderer::Links, :rails, options
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
  
    end
    
  end
end