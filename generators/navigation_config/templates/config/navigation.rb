# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|  
  # Specify a custom renderer if needed. 
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # navigation.renderer = Your::Custom::Renderer
  
  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  # navigation.selected_class = 'your_selected_class'
  
  # Define the primary navigation
  navigation.items do |primary|
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # html_options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #
    primary.item :key_1, 'name', url, html_options
    
    # Add an item which has a sub navigation (same params, but with block)
    primary.item :key_2, 'name', url, html_options do |sub_nav|
      # Add an item to the sub navigation (same params again)
      sub_nav.item :key_2_1, 'name', url, html_options
    end 
  
  end
  
end