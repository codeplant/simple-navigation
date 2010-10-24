require 'spec_helper'

describe SimpleNavigation::Adapters::Padrino do

  def create_adapter
    SimpleNavigation::Adapters::Padrino.new(@context)
  end
  
  before(:each) do
    @request = stub(:request)
    @context = stub(:context, :request => @request)
    @adapter = create_adapter
  end
  
  describe 'link_to' do
    it "should delegate to context" do
      @context.should_receive(:link_to).with('name', 'url', :my_option => true)
      @adapter.link_to('name', 'url', :my_option => true)
    end
  end
  
  describe 'content_tag' do
    it "should delegate to context" do
      @context.should_receive(:content_tag).with('type', 'content', :my_option => true)
      @adapter.content_tag('type', 'content', :my_option => true)
    end
  end
  
end
