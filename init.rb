ActionController::Dispatcher.to_prepare(:user_system_roles) do
  User.send :include, UserModelRoles
  UserSystem.extend UserSystemRoles
  ApplicationController.send :include, UserSystemRolesLoginFilters
end
