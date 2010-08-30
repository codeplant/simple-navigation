require File.dirname(__FILE__) + '/../../spec_helper'

require 'simple_navigation/rails_controller_methods'

describe 'explicit navigation in rails' do

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
    end

    describe 'class_methods' do

      describe 'navigation' do

        def call_navigation(key1, key2=nil)
          ActiveSupport::Deprecation.silence do
            @controller.class_eval do
              navigation key1, key2
            end
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
          ActiveSupport::Deprecation.silence {@controller.current_navigation(:first)}
          @controller.instance_variable_get(:@sn_current_navigation_args).should == [:first]
        end
        it "should set the sn_current_navigation_args as specified" do
          ActiveSupport::Deprecation.silence {@controller.current_navigation(:first, :second)}
          @controller.instance_variable_get(:@sn_current_navigation_args).should == [:first, :second]
        end
      end

    end

  end

  describe 'SimpleNavigation module additions' do

    describe 'handle_explicit_navigation' do
      def args(*args)
        SimpleNavigation.stub!(:explicit_navigation_args => args.compact.empty? ? nil : args)
      end

      before(:each) do
        @controller = stub(:controller)
        SimpleNavigation.stub!(:controller => @controller)
      end

      context 'with explicit navigation set' do
        context 'list of navigations' do
          before(:each) do
            args :first, :second, :third
          end
          it "should set the correct instance var in the controller" do
            @controller.should_receive(:instance_variable_set).with(:@sn_current_navigation_3, :third)
            SimpleNavigation.handle_explicit_navigation
          end
        end
        context 'single navigation' do
          context 'specified key is a valid navigation item' do
            before(:each) do
              @primary = stub(:primary, :level_for_item => 2)
              SimpleNavigation.stub!(:primary_navigation => @primary)
              args :key
            end
            it "should set the correct instance var in the controller" do
              @controller.should_receive(:instance_variable_set).with(:@sn_current_navigation_2, :key)
              SimpleNavigation.handle_explicit_navigation
            end
          end
          context 'specified key is an invalid navigation item' do
            before(:each) do
              @primary = stub(:primary, :level_for_item => nil)
              SimpleNavigation.stub!(:primary_navigation => @primary)
              args :key
            end
            it "should not raise an ArgumentError" do
              lambda {SimpleNavigation.handle_explicit_navigation}.should_not raise_error(ArgumentError)
            end
          end
        end
        context 'hash with level' do
          before(:each) do
            args :level_2 => :key
          end
          it "should set the correct instance var in the controller" do
            @controller.should_receive(:instance_variable_set).with(:@sn_current_navigation_2, :key)
            SimpleNavigation.handle_explicit_navigation
          end
        end
        context 'hash with multiple_levels' do
          before(:each) do
            args :level_2 => :key, :level_1 => :bla
          end
          it "should set the correct instance var in the controller" do
            @controller.should_receive(:instance_variable_set).with(:@sn_current_navigation_2, :key)
            SimpleNavigation.handle_explicit_navigation
          end
        end
      end
      context 'without explicit navigation set' do
        before(:each) do
          args nil
        end
        it "should not set the current_navigation instance var in the controller" do
          @controller.should_not_receive(:instance_variable_set)
          SimpleNavigation.handle_explicit_navigation
        end
      end
    end

    describe 'current_navigation_for' do
      before(:each) do
        @controller = stub(:controller)
        SimpleNavigation.stub!(:controller => @controller)
      end
      it "should access the correct instance_var in the controller" do
        @controller.should_receive(:instance_variable_get).with(:@sn_current_navigation_1)
        SimpleNavigation.current_navigation_for(1)
      end
    end


  end


  
  # it "should extend the ActionController::Base with the ControllerMethods" do
  #   ActionController::Base.should_receive(:include).with(SimpleNavigation::ControllerMethods)
  #   SimpleNavigation.init_framework
  # end
  
  
end

