class AddWorkHistoryToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.references :work_history
    end
  end

  def self.down
    remove_column :users, :work_history
  end
end
