ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'rspec'
require 'action_controller'

module Rails
  module VERSION
    MAJOR = 2
  end
end unless defined? Rails

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'simple_navigation'

# SimpleNavigation.root = './'
RAILS_ROOT = './' unless defined?(RAILS_ROOT)
RAILS_ENV = 'test' unless defined?(RAILS_ENV)


RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

end

# spec helper methods
def sub_items
  [
    [:subnav1, 'subnav1', 'subnav1_url', {}],
    [:subnav2, 'subnav2', 'subnav2_url', {}]
  ]
end

def primary_items
  [
    [:users, 'users', 'first_url', {:id => 'my_id'}],
    [:invoices, 'invoices', 'second_url', {}],
    [:accounts, 'accounts', 'third_url', {:style => 'float:right', :link => {:style => 'float:left'}}]
  ]
end

def primary_container
  container = SimpleNavigation::ItemContainer.new(1)
  container.dom_id = 'nav_dom_id'
  container.dom_class = 'nav_dom_class'
  @items = primary_items.map {|params| SimpleNavigation::Item.new(container, *params)}
  @items.each {|i| i.stub!(:selected? => false)}
  container.instance_variable_set(:@items, @items)
  primary_item(:invoices) {|item| item.instance_variable_set(:@sub_navigation, subnav_container)}
  container
end

def primary_item(key)
  yield @items.find {|i| i.key == key}
end

def select_item(key)
  if(key == :subnav1)
    select_item(:invoices)
    primary_item(:invoices) do |item|
      item.instance_variable_get(:@sub_navigation).items.find { |i| i.key == key}.stub!(:selected? => true)
    end
  else
    primary_item(key) {|item| item.stub!(:selected? => true) unless item.frozen?}
  end
end

def subnav_container
  container = SimpleNavigation::ItemContainer.new(2)
  items = sub_items.map {|params| SimpleNavigation::Item.new(container, *params)}
  items.each {|i| i.stub!(:selected? => false)}
  container.instance_variable_set(:@items, items)
  container
end

def setup_renderer_for(renderer_class, framework, options)
  setup_adapter_for framework
  @renderer = renderer_class.new(options)
end

def setup_adapter_for(framework)
  adapter = case framework
  when :rails
    SimpleNavigation::Adapters::Rails.new(stub(:context, :view_context => ActionView::Base.new))
  end
  SimpleNavigation.stub!(:adapter => adapter)
  adapter
end
