module UserSystemHasGroups

  mattr_accessor :administrators_group
  self.administrators_group = 'Administrators'

  mattr_accessor :default_new_user_groups
  self.default_new_user_groups = ['Users']

  mattr_accessor :public_group_creation
  self.public_group_creation = false

  mattr_accessor :group_creation_moderated
  self.group_creation_moderated = false
end
