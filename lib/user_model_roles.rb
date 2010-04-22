# Hooks so that User speaks Role and RoleActivation
module UserModelRoles

  # When included into User, add relationships and callbacks
  def self.included kls
    kls.send :has_many, :role_activations
    kls.send :has_many, :roles, :through => :role_activations

    kls.send :named_scope, :has_role, lambda{|role|
      role = role.is_a?(Role) ? \
                role.id : \
                role.to_i.nonzero? ? \
                  role.to_i :
                  Role.find_by_lowercase_name(role.downcase)
      {
        :include => {:role_activations => :role},
        :conditions => {
          'role_activations.role_id' => role
        }
      }
    }

    kls.send :attr_accessor, :dont_add_default_roles
    kls.send :after_create, :add_default_roles
  end

  # Join a role, or a list of roles really.  Can be specified by name
  # or record.  Will add the roles it can, and set @error_message if
  # it couldn't add (it will be empty otherwise).
  def add_role *role_list
    passed = true
    @error_message = ""
    records = role_list.flatten.collect do |x|
      x.is_a?(Role) ? x : Role.find_by_lowercase_name(x.to_s.downcase)
    end
    records.compact.each do |x|
      if act = role_activations.find_by_role_id(x.id)
        next
      end
      activation = role_activations.create(:role => x)
      if activation.new_record?
        @error_message += "#{x.name}: #{x.errors.full_messages.inspect}"
        passed = false
      end
    end
    passed
  end

  # The ones in UserSystem.default_new_user_roles
  # To disable this behavior per-user:
  #   user.dont_add_default_roles = true ; user.save
  # or
  #   user.create params[:user].merge(:dont_add_default_roles => true)
  #
  # To disable adding roles for all users, just 
  #   UserSystem.default_new_user_roles = []
  #
  def add_default_roles
    return if @dont_add_default_roles
    add_role UserSystem.default_new_user_roles
  end

  #
  # Give a role name or a role model
  #
  def has_role? role
    grps = role_activations.collect(&:role)
    role = role.is_a?(Role) ? role.lowercase_name : role.to_s.downcase
    grps.any?{|g| g.lowercase_name == role}
  end
end
