class AddRetrievalTimestampToFacebookContact < ActiveRecord::Migration
  def self.up
    add_column :facebook_contacts, :retrieved_at, :timestamp
  end

  def self.down
    remove_column :facebook_contacts, :retrieved_at
  end
end
