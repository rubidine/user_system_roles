class CreateDisabledPeriods < ActiveRecord::Migration
  def self.up
    create_table :disabled_periods do |t|
      t.integer :group_activation_id
      t.timestamp :disabled_from, :disabled_until
      t.string :disabled_message

      t.boolean :permanently_disabled

      t.integer :disabled_by
    end
  end

  def self.down
    drop_table :disabled_periods
  end
end
