class CreateFacebookContacts < ActiveRecord::Migration
  def self.up
    create_table :facebook_contacts do |t|
      t.string :facebook_id
      t.string :name
      t.string :location
      t.references :work_history

      t.timestamps
    end
  end

  def self.down
    drop_table :facebook_contacts
  end
end
