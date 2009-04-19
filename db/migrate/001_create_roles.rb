class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      # basic census information
      t.string :name, :lowercase_name
      t.timestamps 
    end
  end

  def self.down
    drop_table :roles
  end
end
