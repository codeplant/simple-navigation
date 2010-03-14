require File.dirname(__FILE__) + '/../../spec_helper'

ActionController::Base.send(:include, SimpleNavigation::ControllerMethods)

describe SimpleNavigation::ControllerMethods do

  def stub_loading_config
    SimpleNavigation::Configuration.stub!(:load)
  end

  before(:each) do
    stub_loading_config
    class TestController
      class << self
        def helper_method(*args)
          @helper_methods = args
        end
        def before_filter(*args)
          @before_filters = args
        end
      end
    end
    TestController.send(:include, SimpleNavigation::ControllerMethods)
    @controller = TestController.new
  end
  
  describe 'when being included' do
    it "should extend the ClassMethods" do
      @controller.class.should respond_to(:navigation)
    end
    it "should include the InstanceMethods" do
      @controller.should respond_to(:current_navigation)
    end
    it "should install the helper methods" do
      @controller.class.instance_variable_get(:@helper_methods).should == [:render_navigation, :render_primary_navigation, :render_sub_navigation]
    end
  end
  
  describe 'class_methods' do
    
    describe 'navigation' do
      
      def call_navigation(key1, key2=nil)
        @controller.class_eval do
          navigation key1, key2
        end
      end
      
      it "should not have an instance-method 'sn_set_navigation' if navigation-method has not been called" do
        @controller.respond_to?(:sn_set_navigation).should be_false
      end
      it 'should create an instance-method "sn_set_navigation" when being called' do
        call_navigation(:key)
        @controller.respond_to?(:sn_set_navigation).should be_true
      end
      it "the created method should not be public" do
        call_navigation(:key)
        @controller.public_methods.map(&:to_sym).should_not include(:sn_set_navigation)
      end
      it "the created method should be protected" do
        call_navigation(:key)
        @controller.protected_methods.map(&:to_sym).should include(:sn_set_navigation)
      end
      it 'the created method should call current_navigation with the specified keys' do
        call_navigation(:primary, :secondary)
        @controller.should_receive(:current_navigation).with(:primary, :secondary)
        @controller.send(:sn_set_navigation)
      end
    end
    
  end
  
  describe 'instance_methods' do
    
    describe 'current_navigation' do
      it "should set the sn_current_navigation_args as specified" do
        @controller.current_navigation(:first)
        @controller.instance_variable_get(:@sn_current_navigation_args).should == [:first]
      end
      it "should set the sn_current_navigation_args as specified" do
        @controller.current_navigation(:first, :second)
        @controller.instance_variable_get(:@sn_current_navigation_args).should == [:first, :second]
      end
    end
    
  end
  
end