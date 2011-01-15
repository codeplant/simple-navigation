require 'spec_helper'

describe SimpleNavigation::Renderer::Breadcrumbs do

  describe 'render' do

    def render(current_nav=nil, options={:level => :all})
      primary_navigation = primary_container
      select_item(current_nav)
      setup_renderer_for SimpleNavigation::Renderer::Title, :rails, options
      @renderer.render(primary_navigation)
    end
    context 'regarding result' do

      it "should render the selected page" do
        render(:invoices).should == "invoices"
      end

      context 'nested sub_navigation' do
        it "should add an entry for each selected item" do
          render(:subnav1).should == "invoices subnav1"
        end
      end

      context 'with a site_name specified' do
        it "should render the site name even when no current_navigation is set" do
          render(nil, :site_name => "The site").should == "The site"
        end

        it "should render the site_name before the top level navigation" do
          render(:users, :site_name => "The site").should == "The site users"
        end
      end

      context 'with a custom seperator specified' do
        it "should separate the items with the separator" do
          render(:subnav1, :join_with => " | ").should == "invoices | subnav1" 
        end
      end
    end
  end
end
