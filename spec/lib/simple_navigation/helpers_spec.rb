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
      it "should call render on the primary_navigation (specifying level through options)" do
        @primary_navigation.should_receive(:render)
        @controller.render_navigation(:level => 1)
      end
    end
    
    context 'secondary' do
      context 'with current_primary_navigation set' do
        before(:each) do
          @selected_item_container = stub(:selected_container, :null_object => true)
          SimpleNavigation.stub!(:active_item_container_for => @selected_item_container)
        end
        it "should find the selected sub_navigation for the specified level" do
          SimpleNavigation.should_receive(:active_item_container_for).with(2)
          @controller.render_navigation(:secondary)
        end
        it "should find the selected sub_navigation for the specified level" do
          SimpleNavigation.should_receive(:active_item_container_for).with(2)
          @controller.render_navigation(:level => :secondary)
        end
        it "should find the selected sub_navigation for the specified level" do
          SimpleNavigation.should_receive(:active_item_container_for).with(1)
          @controller.render_navigation(:level => 1)
        end
        it "should call render on the active item_container" do
          @selected_item_container.should_receive(:render)
          @controller.render_navigation(:secondary)
        end
      end
      context 'without an active item_container set' do
        before(:each) do
          SimpleNavigation.stub!(:active_item_container_for => nil)
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
      it "should raise an error" do
        lambda {@controller.render_navigation(:level => :unknown)}.should raise_error(ArgumentError)
      end
      it "should raise an error" do
        lambda {@controller.render_navigation('level')}.should raise_error(ArgumentError)
      end
    end
  end
  
  describe 'render_primary_navigation' do  
    it "should delegate to render_navigation(:primary)" do
      ActiveSupport::Deprecation.silence do
        @controller.should_receive(:render_navigation).with(:level => 1)
        @controller.render_primary_navigation
      end
    end
  end
  
  describe 'render_sub_navigation' do
    it "should delegate to render_navigation(:secondary)" do
      ActiveSupport::Deprecation.silence do
        @controller.should_receive(:render_navigation).with(:level => 2)
        @controller.render_sub_navigation
      end
    end
  end
  
end