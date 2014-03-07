require 'simple_navigation/config_file'

module SimpleNavigation
  class ConfigFileFinder
    def initialize(paths)
      @paths = paths
    end

    def find(context)
      config_file_name = config_file_name_for_context(context)

      find_config_file(config_file_name) ||
      fail("Config file '#{config_file_name}' not found in " \
           "path(s) #{paths.join(', ')}!")
    end

    private

    attr_reader :paths

    def config_file_name_for_context(context)
      ConfigFile.new(context).name
    end

    def find_config_file(config_file_name)
      paths.map { |path| File.join(path, config_file_name) }
           .find { |full_path| File.exist?(full_path) }
    end
  end
end
