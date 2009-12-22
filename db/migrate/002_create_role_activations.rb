class CreateRoleActivations < ActiveRecord::Migration
  def self.up
    create_table :role_activations do |t|
      t.integer :role_id, :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :role_activations
  end
end
