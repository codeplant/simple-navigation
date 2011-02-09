require 'spec_helper'

describe SimpleNavigation::Configuration do

  before(:each) do
    @config = SimpleNavigation::Configuration.instance
  end

  describe 'self.run' do
    it "should yield the singleton Configuration object" do
      SimpleNavigation::Configuration.run do |c|
        c.should == @config
      end
    end
  end

  describe 'self.eval_config' do
    before(:each) do
      @context = mock(:context)
      @context.stub!(:instance_eval)
      SimpleNavigation.stub!(:context_for_eval => @context)
      @config_files = {:default => 'default', :my_context => 'my_context'}
      SimpleNavigation.stub!(:config_files).and_return(@config_files)
    end
    context "with default navigation context" do
      it "should instance_eval the default config_file-string inside the context" do
        @context.should_receive(:instance_eval).with('default')
        SimpleNavigation::Configuration.eval_config
      end    
    end
    context 'with non default navigation context' do
      it "should instance_eval the specified config_file-string inside the context" do
        @context.should_receive(:instance_eval).with('my_context')
        SimpleNavigation::Configuration.eval_config(:my_context)
      end
    end
  end

  describe 'initialize' do
    it "should set the List-Renderer as default upon initialize" do
      @config.renderer.should == SimpleNavigation::Renderer::List
    end
    it "should set the selected_class to 'selected' as default" do
      @config.selected_class.should == 'selected'
    end
    it "should set autogenerate_item_ids to true as default" do
      @config.autogenerate_item_ids.should be_true
    end
    it "should set auto_highlight to true as default" do
      @config.auto_highlight.should be_true
    end
    it "should set the id_generator" do
      @config.id_generator.should_not be_nil
    end
    it "should set the name_generator" do
      @config.name_generator.should_not be_nil
    end
  end
  describe 'items' do
    before(:each) do
      @container = stub(:items_container)
      SimpleNavigation::ItemContainer.stub!(:new).and_return(@container)
    end
    context 'block given' do
      context 'items_provider specified' do
        it {lambda {@config.items(stub(:provider)) {}}.should raise_error}
      end
      context 'no items_provider specified' do
        it "should should yield an new ItemContainer" do
          @config.items do |container|
            container.should == @container
          end
        end
        it "should assign the ItemContainer to an instance-var" do
          @config.items {}
          @config.primary_navigation.should == @container
        end
        it "should not set the items on the container" do
          @container.should_not_receive(:items=)
          @config.items {}
        end
      end
    end
    context 'no block given' do
      context 'items_provider specified' do
        before(:each) do
          @external_provider = stub(:external_provider)
          @items = stub(:items)
          @items_provider = stub(:items_provider, :items => @items)
          SimpleNavigation::ItemsProvider.stub!(:new => @items_provider)
          @container.stub!(:items=)
        end
        it "should create an new Provider object for the specified provider" do
          SimpleNavigation::ItemsProvider.should_receive(:new).with(@external_provider)
          @config.items(@external_provider)
        end
        it "should call items on the provider object" do
          @items_provider.should_receive(:items)
          @config.items(@external_provider)
        end
        it "should set the items on the container" do
          @container.should_receive(:items=).with(@items)
          @config.items(@external_provider)
        end
      end
      context 'items_provider not specified' do
        it {lambda {@config.items}.should raise_error}
      end
    end
  end

  describe 'loaded?' do
    it "should return true if primary_nav is set" do
      @config.instance_variable_set(:@primary_navigation, :bla)
      @config.should be_loaded
    end
    it "should return false if no primary_nav is set" do
      @config.instance_variable_set(:@primary_navigation, nil)
      @config.should_not be_loaded
    end
  end
  
end


