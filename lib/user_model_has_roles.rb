# Hooks so that User speaks Role and RoleActivation
module UserModelHasRoles

  # When included into User, add relationships and callbacks
  def self.included kls
    kls.send :has_many, :role_activations
    kls.send :has_many, :roles, :through => :role_activations

    kls.send :named_scope, :member_of, lambda{|role|
      role = role.is_a?(Role) ? \
                role.id : \
                (role.to_i == 0) ? \
                  Role.find_by_lowercase_name(role.downcase) : 
                  role.to_i
      ucond = kls.merge_conditions(
        {'udp.disabled_item_type' => 'User'},
        [
          'udp.disabled_from <= ? ' +
          'AND (udp.disabled_until > ? OR udp.disabled_until IS NULL)',
          Time.now, Time.now
        ]
      )
      gacond = kls.merge_conditions(
        {'gadp.disabled_item_type' => 'RoleActivation'},
        [
          'gadp.disabled_from <= ? ' +
          'AND (gadp.disabled_until > ? OR gadp.disabled_until IS NULL)',
          Time.now, Time.now
        ]
      )
      gcond = kls.merge_conditions(
        {'gdp.disabled_item_type' => 'Role'},
        [
          'gdp.disabled_from <= ? ' +
          'AND (gdp.disabled_until > ? OR gdp.disabled_until IS NULL)',
          Time.now, Time.now
        ]
      )
      {
        :joins =>
          "LEFT JOIN disabled_periods udp ON #{ucond} " +
          "LEFT JOIN disabled_periods gadp ON #{gacond} " +
          "LEFT JOIN disabled_periods gdp ON #{gcond}",
        :include => :role_activations,
        :conditions => {
          'udp.id' => nil,
          'gadp.id' => nil,
          'gdp.id' => nil,
          'role_activations.role_id' => role
        }
      }
    }

    kls.send :attr_accessor, :dont_join_default_roles
    kls.send :after_create, :join_default_roles
  end

  # Join a role, or a list of roles really.  Can be specified by name
  # or record.  Will join the roles it can, and set @error_message if
  # it couldn't join (it will be empty otherwise).
  def join_role *role_list
    passed = true
    @error_message = ""
    records = role_list.flatten.collect do |x|
      x.is_a?(Role) ? x : Role.find_by_lowercase_name(x.downcase)
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
  #   user.dont_join_default_roles = true ; user.save
  # or
  #   user.create params[:user].merge(:dont_join_default_roles => true)
  #
  # To disable joining roles for all users, just 
  #   UserSystem.default_new_user_gruops = []
  #
  def join_default_roles
    return if @dont_join_default_roles
    join_role UserSystem.default_new_user_roles
  end

  # Return a list of roles that the user is active in at this time
  def valid_roles
    role_activations.active.collect(&:role)
  end

  #
  # Give a role name or a role model
  #
  def member_of? role, include_disabled=false
    grps = include_disabled ? role_activations.collect(&:role) : valid_roles
    role = role.is_a?(String) ? role.downcase : role.lowercase_name
    grps.any?{|g| g.lowercase_name == role}
  end
end
