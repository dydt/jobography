class RemoveIdsFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :facebook_contacts_id
    remove_column :users, :work_history_id
  end

  def self.down
    add_column :users, :facebook_contacts_id, :integer
    add_column :users, :work_history_id, :integer
  end
end
