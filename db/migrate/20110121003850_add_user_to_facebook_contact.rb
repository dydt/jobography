class AddUserToFacebookContact < ActiveRecord::Migration
  def self.up
    change_table :facebook_contacts do |t|
      t.references :user
    end
  end

  def self.down
    remove_column :facebook_contacts, :user
  end
end
