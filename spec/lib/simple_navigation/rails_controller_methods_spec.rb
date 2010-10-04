require 'spec_helper'

describe 'explicit navigation in rails' do
  require 'simple_navigation/rails_controller_methods'

  it 'should have enhanced the ActionController after loading the extensions' do
    ActionController::Base.instance_methods.map {|m| m.to_s}.should include('current_navigation')
  end

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

  describe 'SimpleNavigation module additions' do

    describe 'handle_explicit_navigation' do
      def args(*args)
        SimpleNavigation.stub!(:explicit_navigation_args => args.compact.empty? ? nil : args)
      end

      before(:each) do
        @controller = stub(:controller)
        @adapter = stub(:adapter, :controller => @controller)
        SimpleNavigation.stub!(:adapter => @adapter)
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
            it "should raise an ArgumentError" do
              lambda {SimpleNavigation.handle_explicit_navigation}.should raise_error(ArgumentError)
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
        @adapter = stub(:adapter, :controller => @controller)
        SimpleNavigation.stub!(:adapter => @adapter)
      end
      it "should access the correct instance_var in the controller" do
        @controller.should_receive(:instance_variable_get).with(:@sn_current_navigation_1)
        SimpleNavigation.current_navigation_for(1)
      end
    end

  end  

  describe SimpleNavigation::Item do
    before(:each) do
      @item_container = stub(:item_container, :level => 1)
      @item = SimpleNavigation::Item.new(@item_container, :my_key, 'name', 'url', {})
      
    end
    describe 'selected_by_config?' do
      context 'navigation explicitly set' do
        it "should return true if current matches key" do
          SimpleNavigation.stub!(:current_navigation_for => :my_key)
          @item.should be_selected_by_config
        end
        it "should return false if current does not match key" do
          SimpleNavigation.stub!(:current_navigation_for => :other_key)
          @item.should_not be_selected_by_config
        end
      end
      context 'navigation not explicitly set' do
        before(:each) do
          SimpleNavigation.stub!(:current_navigation_for => nil)
        end
        it {@item.should_not be_selected_by_config}
      end
    end
  end
  
  describe SimpleNavigation::ItemContainer do
    describe 'selected_item' do
      before(:each) do
        SimpleNavigation.stub!(:current_navigation_for)
        @item_container = SimpleNavigation::ItemContainer.new
        
        @item_1 = stub(:item, :selected? => false)
        @item_2 = stub(:item, :selected? => false)
        @item_container.instance_variable_set(:@items, [@item_1, @item_2])
      end
      context 'navigation explicitely set' do
        before(:each) do
          @item_container.stub!(:[] => @item_1)
        end
        it "should return the explicitely selected item" do
          @item_container.selected_item.should == @item_1
        end
      end
      context 'navigation not explicitely set' do
        before(:each) do
          @item_container.stub!(:[] => nil)
        end
        context 'no item selected' do
          it "should return nil" do
            @item_container.selected_item.should be_nil
          end
        end
        context 'one item selected' do
          before(:each) do
            @item_1.stub!(:selected? => true)
          end
          it "should return the selected item" do
            @item_container.selected_item.should == @item_1
          end
        end
      end
    end
    
  end
  
end

