require File.dirname(__FILE__) + '/../../spec_helper'

describe SimpleNavigation::Helpers do
  class ControllerMock
    include SimpleNavigation::Helpers
  end
  
  before(:each) do
    @controller = ControllerMock.new
    SimpleNavigation.stub!(:load_config)
    SimpleNavigation::Configuration.stub!(:eval_config)
    @primary_navigation = stub(:primary_navigation, :null_object => true)
    SimpleNavigation.stub!(:primary_navigation).and_return(@primary_navigation)
  end
  
  describe 'render_navigation' do
    describe 'regarding loading of the config-file' do
      context 'no options specified' do
        it "should load the config-file for the default context" do
          SimpleNavigation.should_receive(:load_config).with(:default)
          @controller.render_navigation
        end
      end
      
      context 'with options specified' do
        it "should load the config-file for the specified context" do
          SimpleNavigation.should_receive(:load_config).with(:my_context)
          @controller.render_navigation(:context => :my_context)
        end
      end
    end
    
    it "should eval the config on every request" do
      SimpleNavigation::Configuration.should_receive(:eval_config).with(@controller, :default)
      @controller.render_navigation
    end
    
    context 'primary' do
      it "should call render on the primary_navigation" do
        @primary_navigation.should_receive(:render)
        @controller.render_navigation(:primary)
      end
      it "should call render on the primary_navigation (specifying level through options)" do
        @primary_navigation.should_receive(:render)
        @controller.render_navigation(:level => :primary)
      end
    end
    
    context 'secondary' do
      context 'with current_primary_navigation set' do
        before(:each) do
          @sub_navigation = stub(:sub_navigation, :null_object => true)
          @selected_primary = stub(:selected_primary, :sub_navigation => @sub_navigation)
          @primary_navigation.stub!(:selected_item).and_return(@selected_primary)
        end
        it "should find the sub_navigation belonging to the current primary_navigation" do
          @primary_navigation.should_receive(:selected_item)
          @controller.render_navigation(:secondary)
        end
        it "should call render on the current primary_navigation's sub_navigation" do
          @sub_navigation.should_receive(:render)
          @controller.render_navigation(:secondary)
        end
      end
      context 'without current_primary_navigation set' do
        before(:each) do
          @primary_navigation.stub!(:selected_item => nil)
        end
        it "should not raise an error" do
          lambda{@controller.render_navigation(:secondary)}.should_not raise_error
        end
      end
      
    end
    
    context 'nested' do
      it "should call render on the primary navigation with the include_subnavigation option set" do
        @primary_navigation.should_receive(:render).with(true)
        @controller.render_navigation(:nested)
      end
    end
    
    context 'unknown level' do
      it "should raise an error" do
        lambda {@controller.render_navigation(:unknown)}.should raise_error(ArgumentError)
      end
    end
  end
  
  describe 'render_primary_navigation' do  
    it "should delegate to render_navigation(:primary)" do
      @controller.should_receive(:render_navigation).with(:level => :primary)
      @controller.render_primary_navigation
    end
  end
  
  describe 'render_sub_navigation' do
    it "should delegate to render_navigation(:secondary)" do
      @controller.should_receive(:render_navigation).with(:level => :secondary)
      @controller.render_sub_navigation
    end
  end
  
end