class AddOrigIdToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :orig_id, :string
  end

  def self.down
    remove_column :jobs, :orig_id
  end
end
