require 'simple_navigation/rendering/helpers'
require 'simple_navigation/rendering/renderer/base'

module SimpleNavigation
  module Renderer
    autoload :List, 'simple_navigation/rendering/renderer/list'
    autoload :Links, 'simple_navigation/rendering/renderer/links'
    autoload :Breadcrumbs, 'simple_navigation/rendering/renderer/breadcrumbs'
    autoload :Text, 'simple_navigation/rendering/renderer/text'
  end
end
