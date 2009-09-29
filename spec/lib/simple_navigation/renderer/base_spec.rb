require File.dirname(__FILE__) + '/../../../spec_helper'

describe SimpleNavigation::Renderer::Base do
  before(:each) do
    @controller = stub(:controller)
    SimpleNavigation.stub!(:controller).and_return(@controller)
    @base_renderer = SimpleNavigation::Renderer::Base.new
  end
  it "should inclue ActionView::Helpers::UrlHelper" do
    @base_renderer.should respond_to(:link_to)
  end
  it "should include ActionView::Helpers::TagHelper" do
    @base_renderer.should respond_to(:content_tag)
  end
  
  describe 'delegated methods' do
    it {@base_renderer.should respond_to(:form_authenticity_token)}
    it {@base_renderer.should respond_to(:protect_against_forgery?)}
    it {@base_renderer.should respond_to(:request_forgery_protection_token)}
  end
  
  describe 'initialize' do
    it {@base_renderer.controller.should == @controller}
  end
  
  describe 'controller_method' do
    context 'delegate a single method' do
      before(:each) do
        @base_renderer.class_eval do
          controller_method :my_method
        end
      end
      it 'should delegate a controller_method to the controller' do
        @controller.should_receive(:my_method)
        @base_renderer.my_method
      end
    end
    
    context 'delegate multiple methods' do
      before(:each) do
        @base_renderer.class_eval do
          controller_method :test1, :test2
        end
      end
      it 'should delegate all controller_methods to the controller' do
        @controller.should_receive(:test1)
        @base_renderer.test1
        @controller.should_receive(:test2)
        @base_renderer.test2
      end      
    end
  end
  
  describe 'render' do
    it "be subclass responsability" do
      lambda {@base_renderer.render(:container)}.should raise_error('subclass responsibility')
    end
  end

end
