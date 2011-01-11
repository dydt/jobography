class AddUuidsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_uuid, :integer
    add_column :users, :linked_in_uuid, :integer
    
    add_index :users, :facebook_uuid
    add_index :users, :linked_in_uuid
  end

  def self.down
    remove_column :users, :linked_in_uuid
    remove_column :users, :facebook_uuid
  end
end
