require File.dirname(__FILE__) + '/../spec_helper'

describe SimpleNavigation do

  before(:each) do
    SimpleNavigation.config_file_path = 'path_to_config'
  end

  describe 'config_files' do
    before(:each) do
      SimpleNavigation.config_files = {}
    end
    it "should be an empty hash after loading the module" do
      SimpleNavigation.config_files.should == {}
    end
  end

  describe 'config_file?' do
    it "should check for the file existance with the file_name" do
      File.should_receive(:exists?).with('path_to_config/ctx_navigation.rb')
      SimpleNavigation.config_file?(:ctx)
    end
    context 'for other navigation_context' do
      it "should return the name of the config file matching the specified context" do
        SimpleNavigation.config_file_name(:my_other_context).should == 'my_other_context_navigation.rb'
      end
      it "should convert camelcase-contexts to underscore" do
        SimpleNavigation.config_file_name(:WhyWouldYouDoThis).should == 'why_would_you_do_this_navigation.rb'
      end
    end
  end
  
  describe 'config_file_paths_sentence' do
    context 'no paths are set' do
      before(:each) do
        SimpleNavigation.config_file_paths = []
      end
      it {SimpleNavigation.config_file_paths_sentence.should == ''}
    end
    context 'one path is set' do
      before(:each) do
        SimpleNavigation.config_file_paths = ['first_path']
      end
      it {SimpleNavigation.config_file_paths_sentence.should == 'first_path'}
    end
    context 'two paths are set' do
      before(:each) do
        SimpleNavigation.config_file_paths = ['first_path', 'second_path']
      end
      it {SimpleNavigation.config_file_paths_sentence.should == 'first_path or second_path'}
    end
    context 'three pahts are set' do
      before(:each) do
        SimpleNavigation.config_file_paths = ['first_path', 'second_path', 'third_path']
      end
      it {SimpleNavigation.config_file_paths_sentence.should == 'first_path, second_path, or third_path'}
    end
  end

  describe 'config_file_name' do
    context 'for :default navigation_context' do
      it "should return the path to default config file" do
        SimpleNavigation.config_file_name.should == 'path_to_config/navigation.rb'
      end
      it "should return nil" do
        SimpleNavigation.config_file.should be_nil
      end
    end

    context 'for other navigation_context' do
      it "should return the path to the config file matching the specified context" do
        SimpleNavigation.config_file_name(:my_other_context).should == 'path_to_config/my_other_context_navigation.rb'
      end
      context 'requested config file does exist' do
        before(:each) do
          File.stub!(:exists? => true)
        end
        it "should return the path to the config_file" do
          SimpleNavigation.config_file.should == 'my_config_file_path/navigation.rb'
        end
      end
      context 'requested config file does not exist' do
        before(:each) do
          File.stub!(:exists? => false)
        end
        it "should return nil" do
          SimpleNavigation.config_file.should be_nil        
        end
      end
    end
    context 'multiple config_file_paths are set' do
      before(:each) do
        SimpleNavigation.config_file_paths = ['first_path', 'second_path']
      end
      context 'requested config file does exist' do
        before(:each) do
          File.stub!(:exists? => true)
        end
        it "should return the path to the first matching config_file" do
          SimpleNavigation.config_file.should == 'first_path/navigation.rb'
        end
      end
      context 'requested config file does not exist' do
        before(:each) do
          File.stub!(:exists? => false)
        end
        it "should return nil" do
          SimpleNavigation.config_file.should be_nil        
        end
      end
    end
  end

  describe 'self.init_rails' do
    before(:each) do
      SimpleNavigation.stub!(:default_config_file_path => 'default_path')
      ActionController::Base.stub!(:include)
    end
    context 'SimpleNavigation.config_file_path is already set' do
      before(:each) do
        SimpleNavigation.config_file_path = 'my_path'
      end
      it "should not override the config_file_path" do
        SimpleNavigation.init_rails
        SimpleNavigation.config_file_paths.should == ['my_path']
      end
    end
    context 'SimpleNavigation.config_file_paths are not set' do
      before(:each) do
        SimpleNavigation.config_file_paths = nil
      end
      it "should set the config_file_path to the default" do
        SimpleNavigation.init_rails
        SimpleNavigation.config_file_paths.should == ['default_path']
      end
    end
    it "should extend the ActionController::Base" do
      ActionController::Base.should_receive(:include).with(SimpleNavigation::ControllerMethods)
      SimpleNavigation.init_rails
    end
  end

  describe 'self.default_config_file_path' do
    it {SimpleNavigation.default_config_file_path.should == './config'}
  end

  describe 'regarding renderers' do
    it "should have registered the builtin renderers by default" do
      SimpleNavigation.registered_renderers.should_not be_empty
    end

    describe 'register_renderer' do
      before(:each) do
        @renderer = stub(:renderer)
      end
      it "should add the specified renderer to the list of renderers" do
        SimpleNavigation.register_renderer(:my_renderer => @renderer)
        SimpleNavigation.registered_renderers[:my_renderer].should == @renderer
      end
    end

  end

  describe 'load_config' do
    context 'config_file_path is set' do
      before(:each) do
        SimpleNavigation.config_file_path = 'path_to_config'
      end

      context 'config_file does exist' do
        before(:each) do
          SimpleNavigation.stub!(:config_file? => true)
          IO.stub!(:read => 'file_content')
        end
        it "should not raise an error" do
          lambda{SimpleNavigation.load_config}.should_not raise_error
        end
        it "should read the specified config file from disc" do
          IO.should_receive(:read).with('path_to_config_file')
          SimpleNavigation.load_config
        end
        it "should store the read content in the module (default context)" do
          SimpleNavigation.should_receive(:config_file).with(:default)
          SimpleNavigation.load_config
          SimpleNavigation.config_files[:default].should == 'file_content'
        end
        it "should store the content in the module (non default context)" do
          SimpleNavigation.should_receive(:config_file).with(:my_context)
          SimpleNavigation.load_config(:my_context)
          SimpleNavigation.config_files[:my_context].should == 'file_content'
        end
      end

      context 'config_file does not exist' do
        before(:each) do
          SimpleNavigation.stub!(:config_file? => false)
        end
        it {lambda{SimpleNavigation.load_config}.should raise_error}
      end
    end

    context 'config_file_path is not set' do
      before(:each) do
        SimpleNavigation.config_file_path = nil
      end
      it {lambda{SimpleNavigation.load_config}.should raise_error}
    end

    describe 'regarding caching of the config-files' do
      before(:each) do
        IO.stub!(:read).and_return('file_content')
        SimpleNavigation.config_file_path = 'path_to_config'
        File.stub!(:exists? => true)
      end
      context "RAILS_ENV undefined" do
        before(:each) do
          SimpleNavigation.rails_env = nil
        end
        it "should load the config file twice" do
          IO.should_receive(:read).twice
          SimpleNavigation.load_config
          SimpleNavigation.load_config
        end
      end
      context "RAILS_ENV defined" do
        before(:each) do
          SimpleNavigation.rails_env = 'production'
        end
        context "RAILS_ENV=production" do
          it "should load the config file only once" do
            IO.should_receive(:read).once
            SimpleNavigation.load_config
            SimpleNavigation.load_config
          end
        end

        context "RAILS_ENV=development" do
          before(:each) do
            SimpleNavigation.rails_env = 'development'
          end
          it "should load the config file twice" do
            IO.should_receive(:read).twice
            SimpleNavigation.load_config
            SimpleNavigation.load_config
          end
        end

        context "RAILS_ENV=test" do
          before(:each) do
            SimpleNavigation.rails_env = 'test'
          end
          it "should load the config file twice" do
            IO.should_receive(:read).twice
            SimpleNavigation.load_config
            SimpleNavigation.load_config
          end
        end
      end
      after(:each) do
        SimpleNavigation.config_files = {}
      end
    end
  end

  describe 'config' do
    it {SimpleNavigation.config.should == SimpleNavigation::Configuration.instance}
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

  describe 'active_item_container_for' do
    before(:each) do
      @primary = stub(:primary)
      SimpleNavigation.config.stub!(:primary_navigation => @primary)
    end
    context 'level is :all' do
      it "should return the primary_navigation" do
        SimpleNavigation.active_item_container_for(:all).should == @primary
      end
    end
    context 'level is a Range' do
      it "should take the min of the range to lookup the active container" do
        @primary.should_receive(:active_item_container_for).with(2)
        SimpleNavigation.active_item_container_for(2..3)
      end
    end
    context 'level is an Integer' do
      it "should consider the Integer to lookup the active container" do
        @primary.should_receive(:active_item_container_for).with(1)
        SimpleNavigation.active_item_container_for(1)
      end
    end
    context 'level is something else' do
      it "should raise an ArgumentError" do
        lambda {SimpleNavigation.active_item_container_for('something else')}.should raise_error(ArgumentError)
      end
    end
  end

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

end
