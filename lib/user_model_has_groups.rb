# Hooks so that User speaks Group and GroupActivation
module UserModelHasGroups

  # When included into User, add relationships and callbacks
  def self.included kls
    kls.send :has_many, :group_activations
    kls.send :has_many, :groups, :through => :group_activations

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
    group_activations.select{|x| x.valid?}.map{|x| x.group}
  end
end
