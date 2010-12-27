require 'spec_helper'

describe SimpleNavigation do

  before(:each) do
    SimpleNavigation.config_file_path = 'path_to_config'
  end

  describe 'config_file_name' do
    context 'for :default navigation_context' do
      it "should return the name of the default config file" do
        SimpleNavigation.config_file_name.should == 'navigation.rb'
      end
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
  
  describe 'config_file_path=' do
    before(:each) do
      SimpleNavigation.config_file_paths = ['existing_path']
    end
    it "should override the config_file_paths" do
      SimpleNavigation.config_file_path = 'new_path'
      SimpleNavigation.config_file_paths.should == ['new_path']
    end
  end
  
  describe 'config_file' do
    context 'no config_file_paths are set' do
      before(:each) do
        SimpleNavigation.config_file_paths = []
      end
      it "should return nil" do
        SimpleNavigation.config_file.should be_nil
      end
    end
    context 'one config_file_path is set' do
      before(:each) do
        SimpleNavigation.config_file_paths = ['my_config_file_path']
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
  
  describe 'config_file?' do
    context 'config_file present' do
      before(:each) do
        SimpleNavigation.stub!(:config_file => 'file')
      end
      it {SimpleNavigation.config_file?.should be_true}
    end
    context 'config_file not present' do
      before(:each) do
        SimpleNavigation.stub!(:config_file => nil)
      end
      it {SimpleNavigation.config_file?.should be_false}
    end
  end

  describe 'self.default_config_file_path' do
    before(:each) do
      SimpleNavigation.stub!(:root => 'root')
    end
    it {SimpleNavigation.default_config_file_path.should == 'root/config'}
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

  describe 'set_env' do
    before(:each) do
      SimpleNavigation.config_file_paths = []
      SimpleNavigation.stub!(:default_config_file_path => 'default_path')
      SimpleNavigation.set_env('root', 'my_env')
    end
    it "should set the root" do
      SimpleNavigation.root.should == 'root'
    end
    it "should set the environment" do
      SimpleNavigation.environment.should == 'my_env'
    end
    it "should add the default-config path to the list of config_file_paths" do
      SimpleNavigation.config_file_paths.should == ['default_path']
    end
  end

  describe 'load_config' do
    context 'config_file_path is set' do
      before(:each) do
        SimpleNavigation.stub!(:config_file => 'path_to_config_file')
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
      context "environment undefined" do
        before(:each) do
          SimpleNavigation.stub!(:environment => nil)
        end
        it "should load the config file twice" do
          IO.should_receive(:read).twice
          SimpleNavigation.load_config
          SimpleNavigation.load_config
        end
      end
      context "environment defined" do
        before(:each) do
          SimpleNavigation.stub!(:environment => 'production')
        end
        context "environment=production" do
          it "should load the config file only once" do
            IO.should_receive(:read).once
            SimpleNavigation.load_config
            SimpleNavigation.load_config   
          end
        end
        
        context "environment=development" do
          before(:each) do
            SimpleNavigation.stub!(:environment => 'development')
          end
          it "should load the config file twice" do
            IO.should_receive(:read).twice
            SimpleNavigation.load_config
            SimpleNavigation.load_config
          end
        end
        
        context "environment=test" do
          before(:each) do
            SimpleNavigation.stub!(:environment => 'test')
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
    context 'level is :leaves' do
      it "should return the currently active leaf-container" do
        @primary.should_receive(:active_leaf_container)
        SimpleNavigation.active_item_container_for(:leaves)
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

  describe 'load_adapter' do
    context 'Rails' do
      before(:each) do
        SimpleNavigation.stub!(:framework => :rails)
        SimpleNavigation.load_adapter
      end
      it {SimpleNavigation.adapter_class.should == SimpleNavigation::Adapters::Rails}
    end
    context 'Padrino' do
      before(:each) do
        SimpleNavigation.stub!(:framework => :padrino)
        SimpleNavigation.load_adapter
      end
      it {SimpleNavigation.adapter_class.should == SimpleNavigation::Adapters::Padrino}
    end
    context 'Sinatra' do
      before(:each) do
        SimpleNavigation.stub!(:framework => :sinatra)
        SimpleNavigation.load_adapter
      end
      it {SimpleNavigation.adapter_class.should == SimpleNavigation::Adapters::Sinatra}
    end
  end
  
end
