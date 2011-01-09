class AddAuthlogicConnectToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :active_token_id, :integer
    
    add_index :users, :email
    add_index :users, :persistence_token
    add_index :users, :active_token_id
  end

  def self.down
    remove_index :users, :active_token_id
    remove_index :users, :persistence_token
    remove_index :users, :email
    
    remove_column :users, :active_token_id
  end
end
