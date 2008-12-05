class Group < ActiveRecord::Base
  has_many :group_activations, :include => :user
  belongs_to :moderator, :class_name => 'User'

  validates_presence_of :name, :lowercase_name
  validates_uniqueness_of :lowercase_name
  validates_length_of :name, :minimum => 1

  # Name is used for display, but internally we track groups by all lowercase.
  # We overwrite this to keep the lowercase version in-sync.
  # It can still get out of whack with update_attribute(), but we want
  # to leave a bit of flexibility in.
  def name= new_name
    write_attribute(:name, new_name)
    write_attribute(:lowercase_name, new_name.downcase)
  end

  # This should never ever ever be called.  Lowercase name is just
  # tracked internally to keep a constant reference to the group.
  # It could still get reset with update_attribute(), if you really wanted.
  def lowercase_name= new_name
    raise "Don't set lowercase name directly!"
  end

  def valid_users
    vg = group_activations.select{|act| act.is_valid?}.collect{|x| x.user}
  end
end
