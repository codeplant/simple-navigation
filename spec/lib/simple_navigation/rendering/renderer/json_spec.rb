require 'spec_helper'

describe SimpleNavigation::Renderer::Json do

  describe 'render' do

    def render(current_nav=nil, options={})
      primary_navigation = primary_container
      select_item(current_nav)
      setup_renderer_for SimpleNavigation::Renderer::Json, :rails, options
      @renderer.render(primary_navigation)
    end

    def prerendered_menu
      '[{"name":"users","url":"first_url","selected":false,"items":null},{"name":"invoices","url":"second_url","selected":true,"items":[{"name":"subnav1","url":"subnav1_url","selected":false,"items":null},{"name":"subnav2","url":"subnav2_url","selected":false,"items":null}]},{"name":"accounts","url":"third_url","selected":false,"items":null},{"name":"miscellany","url":null,"selected":false,"items":null}]'
    end

    context 'regarding result' do

      it "should return a string" do
        render(:invoices).class.should == String
      end

      it "should render the selected page" do
        json = parse_json(render(:invoices))
        found = json.any? do |item| 
          item["name"] == "invoices" and item["selected"]
        end
        found.should == true
      end

    end

    context 'regarding hash result' do
      it "should return a hash" do
        render(:invoices, :as_hash => true).class.should == Array
      end

      it "should render the selected page" do
        found = render(:invoices, :as_hash => true).any? do |item|
          item[:name] == "invoices" and item[:selected]
        end
        found.should == true
      end

    end
  end
end
