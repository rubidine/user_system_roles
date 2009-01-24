# Hooks so that User speaks Group and GroupActivation
module UserModelHasGroups

  # When included into User, add relationships and callbacks
  def self.included kls
    kls.send :has_many, :group_activations
    kls.send :has_many, :groups, :through => :group_activations

    kls.send :named_scope, :member_of, lambda{|group|
      group = group.is_a?(Group) ? \
                group.id : \
                (group.to_i == 0) ? \
                  Group.find_by_lowercase_name(group.downcase) : 
                  group.to_i
      ucond = kls.merge_conditions(
        {'udp.disabled_item_type' => 'User'},
        [
          'udp.disabled_from <= ? ' +
          'AND (udp.disabled_until > ? OR udp.disabled_until IS NULL)',
          Time.now, Time.now
        ]
      )
      gacond = kls.merge_conditions(
        {'gadp.disabled_item_type' => 'GroupActivation'},
        [
          'gadp.disabled_from <= ? ' +
          'AND (gadp.disabled_until > ? OR gadp.disabled_until IS NULL)',
          Time.now, Time.now
        ]
      )
      gcond = kls.merge_conditions(
        {'gdp.disabled_item_type' => 'Group'},
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
        :include => :group_activations,
        :conditions => {
          'udp.id' => nil,
          'gadp.id' => nil,
          'gdp.id' => nil,
          'group_activations.group_id' => group
        }
      }
    }

    kls.send :attr_accessor, :dont_join_default_groups
    kls.send :after_create, :join_default_groups
  end

  # Join a group, or a list of groups really.  Can be specified by name
  # or record.  Will join the groups it can, and set @error_message if
  # it couldn't join (it will be empty otherwise).
  def join_group *group_list
    passed = true
    @error_message = ""
    records = group_list.flatten.collect do |x|
      x.is_a?(Group) ? x : Group.find_by_lowercase_name(x.downcase)
    end
    records.compact.each do |x|
      if act = group_activations.find_by_group_id(x.id)
        next
      end
      activation = group_activations.create(:group => x)
      if activation.new_record?
        @error_message += "#{x.name}: #{x.errors.full_messages.inspect}"
        passed = false
      end
    end
    passed
  end

  # The ones in UserSystem.default_new_user_groups
  # To disable this behavior per-user:
  #   user.dont_join_default_groups = true ; user.save
  # or
  #   user.create params[:user].merge(:dont_join_default_groups => true)
  #
  # To disable joining groups for all users, just 
  #   UserSystem.default_new_user_gruops = []
  #
  def join_default_groups
    return if @dont_join_default_groups
    join_group UserSystem.default_new_user_groups
  end

  # Return a list of groups that the user is active in at this time
  def valid_groups
    group_activations.active.collect(&:group)
  end

  #
  # Give a group name or a group model
  #
  def member_of? group, include_disabled=false
    grps = include_disabled ? group_activations.collect(&:group) : valid_groups
    group = group.is_a?(String) ? group.downcase : group.lowercase_name
    grps.any?{|g| g.lowercase_name == group}
  end
end
