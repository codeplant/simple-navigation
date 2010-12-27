require 'spec_helper'

describe SimpleNavigation::Adapters::Rails do

  def create_adapter
    SimpleNavigation::Adapters::Rails.new(@context)
  end

  before(:each) do
    @context = stub(:context)
    @controller = stub(:controller)
    @context.stub!(:controller => @controller)
    @request = stub(:request)
    @template = stub(:template, :request => @request)
    @adapter = create_adapter
  end
  
  describe 'self.register' do
    before(:each) do
      ActionController::Base.stub!(:include)
    end
    it "should call set_env" do
      SimpleNavigation.should_receive(:set_env).with('./', 'test')
      SimpleNavigation.register
    end
    it "should extend the ActionController::Base with the Helpers" do
      ActionController::Base.should_receive(:include).with(SimpleNavigation::Helpers)
      SimpleNavigation.register
    end
    it "should install the helper methods in the controller" do
      ActionController::Base.should_receive(:helper_method).with(:render_navigation)
      ActionController::Base.should_receive(:helper_method).with(:active_navigation_item_name)
      SimpleNavigation.register
    end
    
  end

  describe 'initialize' do
    context 'regarding setting the request' do
      context 'template is present' do
        before(:each) do
          @controller.stub!(:instance_variable_get => @template)
          @adapter = create_adapter
        end
        it {@adapter.request.should == @request}
      end
      context 'template is not present' do
        before(:each) do
          @controller.stub!(:instance_variable_get => nil)
        end
        it {@adapter.request.should be_nil}
      end
    end
    context 'regarding setting the controller' do
      it "should set the controller" do
        @adapter.controller.should == @controller
      end
    end
    context 'regarding setting the template' do
      context 'template is stored in controller as instance_var (Rails2)' do
        context 'template is set' do
          before(:each) do
            @controller.stub!(:instance_variable_get => @template)
            @adapter = create_adapter
          end
          it {@adapter.template.should == @template}
         end
        context 'template is not set' do
          before(:each) do
            @controller.stub!(:instance_variable_get => nil)
            @adapter = create_adapter
          end
          it {@adapter.template.should be_nil}
        end
      end
      context 'template is stored in controller as view_context (Rails3)' do
        context 'template is set' do
          before(:each) do            
            @controller.stub!(:view_context => @template)
            @adapter = create_adapter
          end
          it {@adapter.template.should == @template}
        end
        context 'template is not set' do
          before(:each) do            
            @controller.stub!(:view_context => nil)
            @adapter = create_adapter
          end
          it {@adapter.template.should be_nil}
        end
      end
    end    
  end
  
  describe 'request_uri' do
    context 'request is set' do
      context 'fullpath is defined on request' do
        before(:each) do
          @request = stub(:request, :fullpath => '/fullpath')
          @adapter.stub!(:request => @request)
        end
        it {@adapter.request_uri.should == '/fullpath'}
      end
      context 'fullpath is not defined on request' do
        before(:each) do
          @request = stub(:request, :request_uri => '/request_uri')
          @adapter.stub!(:request => @request)
        end
        it {@adapter.request_uri.should == '/request_uri'}
      end
    end
    context 'request is not set' do
      before(:each) do
        @adapter.stub!(:request => nil)
      end
      it {@adapter.request_uri.should == ''}
    end
  end
  
  describe 'request_path' do
    context 'request is set' do
      before(:each) do
        @request = stub(:request, :path => '/request_path')
        @adapter.stub!(:request => @request)
      end
      it {@adapter.request_path.should == '/request_path'}
    end
    context 'request is not set' do
      before(:each) do
        @adapter.stub!(:request => nil)
      end
      it {@adapter.request_path.should == ''}
    end
  end
  
  describe 'context_for_eval' do
    context 'controller is present' do
      before(:each) do
        @controller = stub(:controller)
        @adapter.instance_variable_set(:@controller, @controller)
      end
      context 'template is present' do
        before(:each) do
          @template = stub(:template)
          @adapter.instance_variable_set(:@template, @template)
        end
        it {@adapter.context_for_eval.should == @template}
      end
      context 'template is not present' do
        before(:each) do
          @adapter.instance_variable_set(:@template, nil)
        end
        it {@adapter.context_for_eval.should == @controller}
      end
    end
    context 'controller is not present' do
      before(:each) do
        @adapter.instance_variable_set(:@controller, nil)
      end
      context 'template is present' do
        before(:each) do
          @template = stub(:template)
          @adapter.instance_variable_set(:@template, @template)
        end
        it {@adapter.context_for_eval.should == @template}
      end
      context 'template is not present' do
        before(:each) do
          @adapter.instance_variable_set(:@template, nil)
        end
        it {lambda {@adapter.context_for_eval}.should raise_error}
      end
    end
  end
  
  describe 'current_page?' do
    context 'template is set' do
      before(:each) do
        @adapter.stub!(:template => @template)
      end
      it "should delegate the call to the template" do
        @template.should_receive(:current_page?).with(:page)
        @adapter.current_page?(:page)
      end
    end
    context 'template is not set' do
      before(:each) do
        @adapter.stub!(:template => nil)
      end
      it {@adapter.should_not be_current_page(:page)}
    end
  end
  
  describe 'link_to' do
    context 'template is set' do
      before(:each) do
        @adapter.stub!(:template => @template)
        @adapter.stub!(:html_safe => 'safe_text')
        @options = stub(:options)
      end
      it "should delegate the call to the template (with html_safe text)" do
        @template.should_receive(:link_to).with('safe_text', 'url', @options)
        @adapter.link_to('text', 'url', @options)
      end
    end
    context 'template is not set' do
      before(:each) do
        @adapter.stub!(:template => nil)
      end
      it {@adapter.link_to('text', 'url', @options).should be_nil}
    end
  end
  
  describe 'content_tag' do
    context 'template is set' do
      before(:each) do
        @adapter.stub!(:template => @template)
        @adapter.stub!(:html_safe => 'safe_text')
        @options = stub(:options)
      end
      it "should delegate the call to the template (with html_safe text)" do
        @template.should_receive(:content_tag).with(:div, 'safe_text', @options)
        @adapter.content_tag(:div, 'text', @options)
      end
    end
    context 'template is not set' do
      before(:each) do
        @adapter.stub!(:template => nil)
      end
      it {@adapter.content_tag(:div, 'text', @options).should be_nil}
    end
  end
  
  describe 'self.extract_controller_from' do
    context 'object responds to controller' do
      before(:each) do
        @context.stub!(:controller => @controller)
      end
      it "should return the controller" do
        @adapter.send(:extract_controller_from, @context).should == @controller
      end
    end
    context 'object does not respond to controller' do
      before(:each) do
        @context = stub(:context)
      end
      it "should return the context" do
        @adapter.send(:extract_controller_from, @context).should == @context
      end
    end
  end
  
  describe 'html_safe' do
    before(:each) do
      @input = stub :input
    end
    context 'input does respond to html_safe' do
      before(:each) do
        @safe = stub :safe
        @input.stub!(:html_safe => @safe)
      end
      it {@adapter.send(:html_safe, @input).should == @safe}
    end
    context 'input does not respond to html_safe' do
      it {@adapter.send(:html_safe, @input).should == @input}
    end
  end
  
  describe 'template_from' do
    context 'Rails3' do 
      before(:each) do
        @controller.stub!(:view_context => 'view')
      end
      it {@adapter.send(:template_from, @controller).should == 'view'}
    end
    context 'Rails2' do
      before(:each) do
        @controller.instance_variable_set(:@template, 'view')
      end
      it {@adapter.send(:template_from, @controller).should == 'view'}
    end
  end
  
end