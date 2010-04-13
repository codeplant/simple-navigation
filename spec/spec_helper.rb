ENV["RAILS_ENV"] = "test"
require 'rubygems'
require 'spec'
require 'active_support'
require 'action_controller'

module Rails
  module VERSION
    MAJOR = 2
  end
end unless defined? Rails

$:.unshift File.dirname(__FILE__)
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'simple_navigation'

SimpleNavigation.rails_root = './'

# Spec::Runner.configure do |config|
  # no special config
# endx

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
    [:accounts, 'accounts', 'third_url', {:style => 'float:right'}]
  ]
end

def primary_container
  container = SimpleNavigation::ItemContainer.new(0)
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
  primary_item(key) {|item| item.stub!(:selected? => true)}
end

def subnav_container
  container = SimpleNavigation::ItemContainer.new(1)
  items = sub_items.map {|params| SimpleNavigation::Item.new(container, *params)}
  items.each {|i| i.stub!(:selected? => false)}
  container.instance_variable_set(:@items, items)
  container
end
