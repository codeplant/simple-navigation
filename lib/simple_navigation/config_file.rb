require 'active_support/core_ext/string'

module SimpleNavigation
  class ConfigFile
    def initialize(context)
      @prefix = prefix_for_context(context)
    end

    def name
      @name ||= "#{prefix}navigation.rb"
    end

    private

    attr_reader :prefix

    def prefix_for_context(context)
      context == :default ? '' : "#{context.to_s.underscore}_"
    end
  end
end
