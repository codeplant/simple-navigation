require 'initializers/have_css_matcher'
require 'action_controller'
require 'coveralls'
require 'html/document'

Coveralls.wear!

# FIXME: actualize to make it 4 by default
unless defined? Rails
  module Rails
    module VERSION
      MAJOR = 2
    end
  end
end

RAILS_ROOT = './' unless defined?(RAILS_ROOT)
RAILS_ENV = 'test' unless defined?(RAILS_ENV)

require 'simple_navigation'

def setup_adapter_for(framework)
  adapter = case framework
            when :rails
              context = double(:context, view_context: ActionView::Base.new)
              SimpleNavigation::Adapters::Rails.new(context)
            end
  SimpleNavigation.stub(adapter: adapter)
  adapter
end

def setup_renderer(renderer_class, options)
  renderer_class.new(options)
end

def primary_navigation
  # TODO
  primary_container
end

def select_an_item(item)
  item.stub(selected?: true)
end

def setup_container(dom_id, dom_class)
  container = SimpleNavigation::ItemContainer.new(1)
  container.dom_id = dom_id
  container.dom_class = dom_class
  container
end

def setup_navigation(dom_id, dom_class)
  setup_adapter_for :rails
  container = setup_container(dom_id, dom_class)
  setup_items(container)
  container
end

# FIXME: adding the :link option for the list renderer messes up the other
#        renderers
def setup_items(container)
  container.item :users, 'Users', '/users', id: 'users_id', link: { id: 'users_link_id' }
  container.item :invoices, 'Invoices', '/invoices' do |invoices|
    invoices.item :paid, 'Paid', '/invoices/paid'
    invoices.item :unpaid, 'Unpaid', '/invoices/unpaid'
  end
  container.item :accounts, 'Accounts', '/accounts', style: 'float:right', link: { style: 'float:left' }
  container.item :miscellany, 'Miscellany'

  container.items.each do |item|
    item.stub(selected?: false, selected_by_condition?: false)

    if item.sub_navigation
      item.sub_navigation.items.each do |item|
        item.stub(selected?: false, selected_by_condition?: false)
      end
    end
  end
end
