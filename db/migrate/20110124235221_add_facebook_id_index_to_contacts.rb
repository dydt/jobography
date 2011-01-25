class AddFacebookIdIndexToContacts < ActiveRecord::Migration
  def self.up
    add_index :facebook_contacts, :facebook_id
  end

  def self.down
    remove_index :facebook_contacts, :facebook_id
  end
end
