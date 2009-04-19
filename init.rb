# 'directory' is defined in rails plugin loading, and since we are eval'd
# instead of required, we get it here.  But radiant seems to require or load
# instead of eval, so work with it.  Also it can be defined as a function during
# migrations for some reason.
unless defined?(directory) == 'local-variable'
  directory = File.dirname(__FILE__)
end

# Load the extension mojo that hacks into the rails base classes.
require File.join(directory, 'ext_lib', 'init.rb')

# define some routes
ActionController::Routing::Routes.define_user_system_has_roles_routes do |map|
  set = map.instance_variable_get(:@set)
  routes = set.routes
  builder = set.builder
  route = builder.build('/users/inform_norole', {:controller => 'users', :action => "inform_norole", :method => :get})
  position = 0
  while routes[position]
    break if  routes[position].defaults[:controller] == "users" \
          and routes[position].defaults[:action] == "show"
    position += 1
  end
  routes.insert position, route
end

# Monkey patch into the core classes.
#
# There are two ways to do this, if you are patching into a core class
# like ActiveRecord::Base then you can include a class defined by a file
# in this plugin's lib directory
#
# ActiveRecord::Base.send :include, MyClassInLibDirectory
#
# If you are patching a class in the current application, such as a specific
# model that will get reloaded by the dependencies mechanism (in development
# mode) you will need your extension to be reloaded each time the application
# is reset, so use the hook we provide for you.
#
ActiveSupport::Dependencies.register_user_system_has_roles_extension do
  User.send :include, UserModelHasRoles
  UserSystem.extend UserSystemHasRoles
  ApplicationController.send :include, UserSystemHasRolesLoginFilters
end
