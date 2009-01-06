class GroupActivation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  has_many :disabled_periods, :as => :disabled_item
  belongs_to :current_disabled_period,
             :foreign_key => :disabled_period_id,
             :class_name => 'DisabledPeriod'

  validates_presence_of :user, :group

  named_scope :active, 
              lambda{
                cond = merge_conditions(
                         {'disabled_periods.disabled_item_type' => 'GroupActivation'},
                         [
                           'disabled_periods.disabled_from <= ? ' +
                           'AND (disabled_periods.disabled_until > ? ' +
                           'OR disabled_periods.disabled_until IS NULL)',
                           Time.now, Time.now
                         ]
                       )
                {
                  :joins => [
                    "LEFT JOIN disabled_periods ON #{cond} " +
                    "AND disabled_periods.disabled_item_id = group_activations.id"
                  ],
                  :conditions => {'disabled_periods.id' => nil}
                }
              }

  def disabled?
    return false unless disabled_until

    time = Time.now
    return true if disabled_until > time

    # If it was marked as disabled, and the time has elapsed
    # see if there is another disabled period that has come on since then
    compute_disabled

    # Will be null if not disabled
    return disabled_unil
  end

  def disable! until_time=nil
    until_time and (until_time = nil if until_time < Time.now)
    update_attribute(:disabled_from, Time.now)
    update_attribute(:disabled_until, until_time)
  end

  def enable! enabled_since=Time.now
    return unless disabled_from
    enabled_since = disabled_from if disabled_from > enabled_since
    update_attribute(:disabled_until, until_time)
  end

  def is_valid?
    !disabled?
  end

  private
  def compute_disabled
    time = Time.now
    if period = disabled_periods.disabled_at(time).ordered.find(:first)
      self.update_attributes(
        :disabled_until => period.disabled_until,
        :disabled_period_id => period.id
      )
    else
      self.update_attributes(
        :disabled_until => nil,
        :disabled_period_id => nil
      )
    end
  end
end
