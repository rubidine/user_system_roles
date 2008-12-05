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
        if (valid_groups & GroupActivation.valid_for_user(current_user).collect(&:group)).empty?
          session[:last_params] = params
          session[:required_groups] = valid_groups
          redirect_to :controller => '/users', :action => 'inform_nogroup'
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
    grps = GroupActivation.valid_for_user(current_user) if cu

    if !valid_users.empty? and (!cu or !valid_users.include(cu))
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
      options = groups.last.is_a?(Hash) ? groups.pop : {}
      _groups = groups.collect{|x| groupify(x.downcase) }
      before_filter(options) do |inst|
        inst.send(:require_group_login, *_groups)
      end
    end

    def only_for_users_or_groups users, groups, options = {}
      _groups = groups.collect{|x| Groups.find_by_lowercase_name(x.downcase) }
      _users = users.collect{|x| User.find_by_lowercase_login(x.downcase) }
      before_filter(options) do
        require_user_or_group_login(_users, _groups)
      end
    end

    def to_model(str_or_model, model_class, finder)
      if str_or_model.is_a?(model_class)
        str_or_model
      else
        model_class.send(finder, str_or_model)
      end
    end

    def groupify(str_or_group)
      to_model(str_or_group, Group, :find_by_lowercase_name)
    end

    def userify(str_or_user)
      to_model(str_or_group, User, :find_by_lowercase_name)
    end
  end
end
