class RemoveWorkHistoryFromFbContact < ActiveRecord::Migration
  def self.up
    remove_column :facebook_contacts, :work_history_id
  end

  def self.down
    add_column :facebook_contacts, :work_history_id, :integer
  end
end
