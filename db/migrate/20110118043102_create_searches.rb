class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string :query
      t.string :location
      t.references :user

      t.timestamps
    end
    add_index :searches, :created_at
  end

  def self.down
    drop_table :searches
  end
end
