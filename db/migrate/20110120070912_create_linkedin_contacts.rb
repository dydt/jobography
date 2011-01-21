class CreateLinkedinContacts < ActiveRecord::Migration
  def self.up
    create_table :linkedin_contacts do |t|
      t.string :linkedin_id
      t.string :name
      t.string :location
      t.integer :work_history_id

      t.timestamps
    end
  end

  def self.down
    drop_table :linkedin_contacts
  end
end
