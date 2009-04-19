module UserSystemHasRoles

  mattr_accessor :administrators_role
  self.administrators_role = 'Administrators'

  mattr_accessor :default_new_user_roles
  self.default_new_user_roles = ['Users']

  mattr_accessor :public_role_creation
  self.public_role_creation = false

  mattr_accessor :role_creation_moderated
  self.role_creation_moderated = false
end
