require 'spec_helper'
require 'html/document'# unless defined? HTML::Document

describe SimpleNavigation::Renderer::Breadcrumbs do

  describe 'render' do

    def render(current_nav=nil, options={:level => :all})
      primary_navigation = primary_container
      select_item(current_nav) if current_nav
      setup_renderer_for SimpleNavigation::Renderer::Breadcrumbs, :rails, options
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
  
        context 'without current_navigation set' do
          it "should not render any a-tag in the div-tag" do
            HTML::Selector.new('div a').select(render).should have(0).entries
          end
        end

      context 'with current_navigation set' do
        before(:each) do
          @selection = HTML::Selector.new('div a').select(render(:invoices))
        end
        it "should render the selected a tags" do
          @selection.should have(1).entries
        end

        it "should not render class or id" do
          @selection.each do |tag|
            raise unless tag.name == "a"
            tag["id"].should be_nil
            tag["class"].should be_nil
          end
        end
      end


      context 'nested sub_navigation' do
        it "should add an a tag for each selected item" do
          HTML::Selector.new('div a').select(render(:subnav1)).should have(2).entries
        end
      end
    end
  end
end
