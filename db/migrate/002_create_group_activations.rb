class CreateGroupActivations < ActiveRecord::Migration
  def self.up
    create_table :group_activations do |t|
      t.integer :group_id, :user_id

      t.timestamp :disabled_until
      t.integer :disabled_period_id

      t.timestamps
    end
  end

  def self.down
    drop_table :group_activations
  end
end
