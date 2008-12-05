class GroupActivation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  has_many :disabled_periods
  belongs_to :current_disabled_period,
             :foreign_key => :disabled_period_id,
             :class_name => 'DisabledPeriod'

  validates_presence_of :user, :group

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

  def self.valid_for_user user_record
    find(:all, :conditions => {:user_id => user_record.id, :disabled_until => nil})
  end

  private
  def compute_disabled
    time = Time.now
    period = disabled_periods.find(
               :first,
               :conditions => [
                 'disabled_until > ? and disabled_from <= ?',
                 time, time
               ],
               :order => 'disabled_until desc'
             )
    if period
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
