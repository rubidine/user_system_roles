module UserSystemRoles

  mattr_accessor :administrators_role
  self.administrators_role = 'Administrator'

  mattr_accessor :default_new_user_roles
  self.default_new_user_roles = ['Member']

end
