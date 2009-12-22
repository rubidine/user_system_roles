module UserSystemRoles

  mattr_accessor :administrators_role
  self.administrators_role = 'Administrators'

  mattr_accessor :default_new_user_roles
  self.default_new_user_roles = ['Users']

end
