# load Dispatcher if not present yet
unless defined?(ActionController) and defined?(ActionController::Dispatcher)
  require 'action_controller/dispatcher'
end

# Routing Extension
require File.join(File.dirname(__FILE__), 'user_system_has_groups_routing_extension')
ActionController::Routing::RouteSet.send :include, UserSystemHasGroupsRoutingExtension

# Dependency reload mechanism
require File.join(File.dirname(__FILE__), 'user_system_has_groups_dependency_extension')
ActiveSupport::Dependencies.extend UserSystemHasGroupsDependencyExtension

# Load paths go after rails app's own lib/, before previously loaded plugins
ali = $LOAD_PATH.index(File.join(RAILS_ROOT, 'lib')) || 0
paths = [
  File.join(File.dirname(__FILE__), '..', 'app', 'controllers'),
  File.join(File.dirname(__FILE__), '..', 'app', 'helpers'),
  File.join(File.dirname(__FILE__), '..', 'app', 'models'),
  File.join(File.dirname(__FILE__), '..', 'lib')
]
paths.each do |p|
  $LOAD_PATH.insert(ali + 1, p)
  ActiveSupport::Dependencies.load_paths << p
end

ActionController::Base.prepend_view_path File.join(File.dirname(__FILE__), '..', 'app', 'views')

# copy in assets
require 'fileutils'
['javascripts', 'stylesheets', 'images'].each do |type|
  r_path = File.join(RAILS_ROOT, 'public', type, 'user_system_has_groups')
  p_path = File.join(File.dirname(__FILE__), '..', 'public', type)
  unless File.directory?(r_path)
    FileUtils.mkdir_p(r_path)
  end
  Dir["#{p_path}/*"].each do |asset|
    unless File.exist?(File.join(r_path, File.basename(asset)))
      FileUtils.copy(asset, r_path)
    end
  end
end
