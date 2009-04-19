module UserSystemHasRolesRoutingExtension

  def draw_with_user_system_has_roles
    draw_without_user_system_has_roles do |map|
      if @user_system_has_roles_route_block
        @user_system_has_roles_route_block.call(map)
      end
      yield map
    end
  end

  def define_user_system_has_roles_routes &blk
    @user_system_has_roles_route_block = blk
  end

  public
  def self.included(base)
    base.send :alias_method_chain, :draw, :user_system_has_roles
  end

end
