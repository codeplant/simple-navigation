require File.dirname(__FILE__) + '/../../spec_helper'

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
      @config_file = stub(:config_file)
      SimpleNavigation.stub!(:config_file).and_return(@config_file)
    end
    it "should instance_eval the config_file-string inside the context" do
      @context.should_receive(:instance_eval).with(@config_file)
      SimpleNavigation::Configuration.eval_config(@context)
    end    
  end

  describe 'initialize' do
    it "should set the List-Renderer as default upon initialize" do
      @config.renderer.should == SimpleNavigation::Renderer::List
    end
    it "should set the selected_class to 'selected' as default" do
      @config.selected_class.should == 'selected'
    end
  end  
  describe 'items' do
    before(:each) do
      @container = stub(:items_container)
      SimpleNavigation::ItemContainer.stub!(:new).and_return(@container)
    end
    it "should should yield an new ItemContainer" do
      @config.items do |container|
        container.should == @container
      end
    end
    it "should assign the ItemContainer to an instance-var" do
      @config.items {}
      @config.primary_navigation.should == @container
    end
  end

  
end


