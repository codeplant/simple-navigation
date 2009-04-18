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
      context "RAILS_ENV undefined" do
        before(:each) do
          ::RAILS_ENV = nil
        end
        it "should load the config file" do
          SimpleNavigation.should_receive(:load_config)
          @controller.render_navigation
        end
      end
      context "RAILS_ENV defined" do
        before(:each) do
          ::RAILS_ENV = 'production'
        end
        context "RAILS_ENV=production" do
          it "should not load the config file" do
            SimpleNavigation.should_not_receive(:load_config)
            @controller.render_navigation          
          end
        end
        
        context "RAILS_ENV=development" do
          before(:each) do
            ::RAILS_ENV = 'development'
          end
          it "should load the config file" do
            SimpleNavigation.should_receive(:load_config)
            @controller.render_navigation
          end
        end
        
        context "RAILS_ENV=test" do
          before(:each) do
            ::RAILS_ENV = 'test'
          end
          it "should load the config file" do
            SimpleNavigation.should_receive(:load_config)
            @controller.render_navigation
          end
        end
      end
    end
    
    it "should eval the config on every request" do
      SimpleNavigation::Configuration.should_receive(:eval_config).with(@controller)
      @controller.render_navigation
    end
    
    context 'primary' do
      before(:each) do
        @controller.instance_variable_set(:@current_primary_navigation, :current_primary)
      end
      it "should call render on the primary_navigation" do
        @primary_navigation.should_receive(:render).with(:current_primary)
        @controller.render_navigation(:primary)
      end
    end
    
    context 'secondary' do
      context 'with current_primary_navigation set' do
        before(:each) do
          @sub_navigation = stub(:sub_navigation, :null_object => true)
          @primary_navigation.stub!(:[]).and_return(@sub_navigation)
          @controller.instance_variable_set(:@current_primary_navigation, :current_primary)
          @controller.instance_variable_set(:@current_secondary_navigation, :current_secondary)
        end
        it "should find the sub_navigation belonging to the current primary_navigation" do
          @primary_navigation.should_receive(:[]).with(:current_primary)
          @controller.render_navigation(:secondary)
        end
        it "should call render on the current primary_navigation's sub_navigation" do
          @sub_navigation.should_receive(:render).with(:current_secondary)
          @controller.render_navigation(:secondary)
        end
      end
      context 'without current_primary_navigation set' do
        before(:each) do
          @primary_navigation.stub!(:[]).and_return(nil)
          @controller.instance_variable_set(:@current_primary_navigation, nil)
        end
        it "should not raise an error" do
          lambda{@controller.render_navigation(:secondary)}.should_not raise_error
        end
      end
      
    end
    
    context 'nested' do
      before(:each) do
        @controller.instance_variable_set(:@current_primary_navigation, :current_primary)
        @controller.instance_variable_set(:@current_secondary_navigation, :current_secondary)
      end
      it "should call render on the primary navigation" do
        @primary_navigation.should_receive(:render).with(anything, anything, anything)
        @controller.render_navigation(:nested)
      end
      it "should call render with the current_primary_navigation" do
        @primary_navigation.should_receive(:render).with(:current_primary, anything, anything)
        @controller.render_navigation(:nested)
      end
      it "should call render with the include_subnavigation option set" do
        @primary_navigation.should_receive(:render).with(anything, true, anything)
        @controller.render_navigation(:nested)
      end
      it "should call render with the current_sub_navigation" do
        @primary_navigation.should_receive(:render).with(anything, anything, :current_secondary)
        @controller.render_navigation(:nested)
      end
    end
    
    context 'unknown level' do
      it {lambda {@controller.render_navigation(:unknown)}.should raise_error(ArgumentError)}
    end
  end
  
  describe 'render_primary_navigation' do  
    it "should delegate to render_navigation(:primary)" do
      @controller.should_receive(:render_navigation).with(:primary)
      @controller.render_primary_navigation
    end
  end
  
  describe 'render_sub_navigation' do
    it "should delegate to render_navigation(:secondary)" do
      @controller.should_receive(:render_navigation).with(:secondary)
      @controller.render_sub_navigation
    end
  end
  
end