class AddLatLngToFacebookContact < ActiveRecord::Migration
  def self.up
    add_column :facebook_contacts, :lat, :float
    add_column :facebook_contacts, :long, :float
  end

  def self.down
    remove_column :facebook_contacts, :long
    remove_column :facebook_contacts, :lat
  end
end
