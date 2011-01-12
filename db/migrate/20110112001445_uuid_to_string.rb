class UuidToString < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.remove :facebook_uuid
      t.remove :linked_in_uuid
      
      t.string :facebook_id
      t.string :linked_in_id
    end
    add_index :users, :facebook_id
    add_index :users, :linked_in_id
  end

  def self.down
    remove_column :users, :facebook_id
    remove_coumn :users, :linked_in_id
    
    add_column :users, :facebook_uuid, :integer
    add_column :users, :linked_in_uuid, :integer
    
    add_index :users, :facebook_uuid
    add_index :users, :linked_in_uuid
  end
end
