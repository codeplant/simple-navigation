# frozen_string_literal: true

module SimpleNavigation
  # Explicit namespace for the renderers living in renderer/.
  #
  # Without this file Zeitwerk would infer SimpleNavigation::Renderer as an
  # implicit namespace from the renderer/ directory. That inference is not
  # resolved reliably on every runtime (e.g. JRuby, see issue #237), so the
  # namespace is defined explicitly here.
  module Renderer
  end
end
