# frozen_string_literal: true

module SimpleNavigation
  # Explicit namespace for the framework adapters living in adapters/.
  #
  # Without this file Zeitwerk would infer SimpleNavigation::Adapters as an
  # implicit namespace from the adapters/ directory. That inference is not
  # resolved reliably on every runtime (e.g. JRuby, see issue #237), so the
  # namespace is defined explicitly here.
  module Adapters
  end
end
