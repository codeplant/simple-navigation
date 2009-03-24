# Install hook code here
# TODO create config/navigation.rb from template
# TODO show README in console

def copy_config_file
  config_file_template = File.join(File.dirname(__FILE__), 'templates', 'navigation.rb')
  rails_config_file = File.join(RAILS_ROOT, 'config', 'navigation.rb')
  FileUtils.cp config_file_template, rails_config_file, :verbose => true unless File.exist?(rails_config_file)
end

begin
  copy_config_file
rescue Exception => e
  puts "The following error ocurred while installing the plugin: #{e.message}"
end
