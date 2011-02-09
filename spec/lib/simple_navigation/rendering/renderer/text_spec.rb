require 'spec_helper'

describe SimpleNavigation::Renderer::Text do

  describe 'render' do

    def render(current_nav=nil, options={:level => :all})
      primary_navigation = primary_container
      select_item(current_nav)
      setup_renderer_for SimpleNavigation::Renderer::Text, :rails, options
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

      context 'with a custom seperator specified' do
        it "should separate the items with the separator" do
          render(:subnav1, :join_with => " | ").should == "invoices | subnav1" 
        end
      end
      
      context 'custom name generator is set' do
        before(:each) do
          SimpleNavigation.config.name_generator = Proc.new {|name| "<span>name</span>"}
        end
        it "should not apply the name generator (since it is text only)" do
          render(:subnav1, :join_with => " | ").should == "invoices | subnav1" 
        end
      end
    end
  end
end
