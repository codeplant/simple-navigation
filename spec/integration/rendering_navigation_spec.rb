# frozen_string_literal: true

RSpec.feature 'Rendering navigation' do
  background do
    SimpleNavigation.set_env(RailsApp::Application.root, 'test')
  end

  scenario 'Rendering basic navigation', type: :feature do # rubocop:disable RSpec/MultipleExpectations
    visit '/base_spec'

    expect(page).to have_content('Item 1')
    expect(page).to have_content('Item 2')
    expect(page).to have_css('li.item_1 a#link_1')
    expect(page).to have_css('li.item_2 a#link_2')
  end
end
