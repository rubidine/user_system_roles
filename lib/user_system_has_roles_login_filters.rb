module UserSystemHasRolesLoginFilters
  private
  def self.included kls
    kls.send :extend, ClassMethods
  end

  def require_role_login *valid_roles
    if require_user_login
      if valid_roles.empty?
        true
      else
        if (valid_roles & current_user.role_activations.collect(&:role).collect(&:lowercase_name)).empty?
          render :template => 'users/inform_norole',
                 :locals => {:required_roles => valid_roles},
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
  
  def require_user_or_role_login valid_users, valid_roles
    cu = current_user
    grps = current_user.role_activations.collect(&:role) if cu

    if !valid_users.empty? and (!cu or !valid_users.include(cu.lowercase_login))
      # TODO: remove static messages
      flash.now[:notice] = "You need to login to proceed."
      redirect_to new_session_url
      return false
    end

    if !valid_roles.empty? and (!cu or (valid_roles & grps).empty?)
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

    if cu and !cu.verified? and UserAndRoleSystem.verify_email
      redirect_to :controller => '/users', :action => 'request_verification'
      return false
    end

    true
  end

  module ClassMethods
    def only_for_role *roles
      options = roles.extract_options!
      roles = roles.map &:downcase
      before_filter(options) do |inst|
        inst.send(:require_role_login, *roles)
      end
    end

    def only_for_users_or_roles users, roles, options = {}
      users = users.map &:downcase
      roles = roles.map &:downcase
      before_filter(options) do
        require_user_or_role_login(users, roles)
      end
    end
  end
end
