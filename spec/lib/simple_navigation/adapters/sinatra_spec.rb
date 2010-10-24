require 'spec_helper'

describe SimpleNavigation::Adapters::Sinatra do

  def create_adapter
    SimpleNavigation::Adapters::Sinatra.new(@context)
  end

  before(:each) do
    @context = stub(:context)
    @request = stub(:request, :fullpath => '/full?param=true', :path => '/full')
    @context.stub!(:request => @request)
    @adapter = create_adapter
  end

  describe 'context_for_eval' do
    it "should raise error if no context" do
      @adapter.stub!(:context => nil)
      lambda {@adapter.context_for_eval}.should raise_error
    end
    it "should return the context" do
      @adapter.context_for_eval.should == @context
    end
  end
  
  describe 'request_uri' do
    it {@adapter.request_uri.should == '/full?param=true'}
  end
  
  describe 'request_path' do
    it {@adapter.request_path.should == '/full'}
  end
  
  describe 'current_page?' do
    before(:each) do
      @request.stub!(:protocol => 'http://', :host_with_port => 'my_host:5000')
    end
    it {@adapter.current_page?('/full?param=true').should be_true}
    it {@adapter.current_page?('/full?param3=true').should be_false}
    it {@adapter.current_page?('/full').should be_true}
    it {@adapter.current_page?('http://my_host:5000/full?param=true').should be_true}
    it {@adapter.current_page?('http://my_host:5000/full?param3=true').should be_false}
    it {@adapter.current_page?('http://my_host:5000/full').should be_true}
    it {@adapter.current_page?('http://my_host:6000/full').should be_false}
    it {@adapter.current_page?('http://my_other_host:5000/full').should be_false}
  end
  
  describe 'link_to' do
    it "should return a link" do
      @adapter.link_to('link', 'url', :class => 'clazz', :id => 'id').should == "<a href='url' class='clazz' id='id'>link</a>"
    end
  end
  
  describe 'content_tag' do
    it "should return a tag" do
      @adapter.content_tag(:div, 'content', :class => 'clazz', :id => 'id').should == "<div class='clazz' id='id'>content</div>"
    end
  end
  
end