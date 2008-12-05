module UserSystemHasGroupsRoutingExtension

  def draw_with_user_system_has_groups
    draw_without_user_system_has_groups do |map|
      if @user_system_has_groups_route_block
        @user_system_has_groups_route_block.call(map)
      end
      yield map
    end
  end

  def define_user_system_has_groups_routes &blk
    @user_system_has_groups_route_block = blk
  end

  public
  def self.included(base)
    base.send :alias_method_chain, :draw, :user_system_has_groups
  end

end
