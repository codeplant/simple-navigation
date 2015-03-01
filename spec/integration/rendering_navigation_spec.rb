RSpec.feature 'Rendering navigation' do
  background do
    SimpleNavigation.set_env(RailsApp::Application.root, 'test')
  end

  scenario 'Rendering basic navigation', type: :feature do
    visit '/base_spec'

    expect(page).to have_content('Item 1')
    expect(page).to have_content('Item 2')
  end
end
