module UserSystemHasGroupsLoginFilters
  private
  def self.included kls
    kls.send :extend, ClassMethods
  end

  def require_group_login *valid_groups
    if require_user_login
      if valid_groups.empty?
        true
      else
        if (valid_groups & current_user.group_activations.active.collect(&:group).collect(&:name)).empty?
          render :template => 'users/inform_nogroup',
                 :locals => {:required_groups => valid_groups},
                 :status => 403
          false
        else
          true
        end
      end
    else
      false
    end
  end
  
  def require_user_or_group_login valid_users, valid_groups
    cu = current_user
    grps = current_user.group_activations.active.collect(&:group) if cu

    if !valid_users.empty? and (!cu or !valid_users.include(cu.lowercase_login))
      # TODO: remove static messages
      flash.now[:notice] = "You need to login to proceed."
      redirect_to new_session_url
      return false
    end

    if !valid_groups.empty? and (!cu or (valid_groups & grps).empty?)
      session[:last_params] = params
      # TODO: remove static messages
      flash.now[:notice] = 'You need to login to proceed.'
      redirect_to new_session_url
      return false
    end

    if cu and cu.disabled?
      redirect_to :controller => '/users', :action => 'inform_disabled'
      return false
    end

    if cu and !cu.verified? and UserAndGroupSystem.verify_email
      redirect_to :controller => '/users', :action => 'request_verification'
      return false
    end

    true
  end

  module ClassMethods
    def only_for_group *groups
      options = groups.extract_options!
      groups = groups.map &:downcase
      before_filter(options) do |inst|
        inst.send(:require_group_login, *groups)
      end
    end

    def only_for_users_or_groups users, groups, options = {}
      users = users.map &:downcase
      groups = groups.map &:downcase
      before_filter(options) do
        require_user_or_group_login(users, groups)
      end
    end
  end
end
