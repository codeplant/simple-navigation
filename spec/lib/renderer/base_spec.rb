require File.dirname(__FILE__) + '/../../spec_helper'

describe SimpleNavigation::Renderer::Base do
  before(:each) do
    @base_renderer = SimpleNavigation::Renderer::Base.new(:current_primary, :current_secondary)
  end
  it "should inclue ActionView::Helpers::UrlHelper" do
    @base_renderer.should respond_to(:link_to)
  end
  it "should include ActionView::Helpers::TagHelper" do
    @base_renderer.should respond_to(:content_tag)
  end
  it {@base_renderer.current_navigation.should == :current_primary}
  it {@base_renderer.current_sub_navigation.should == :current_secondary}
end
