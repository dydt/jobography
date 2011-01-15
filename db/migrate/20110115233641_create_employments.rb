class CreateEmployments < ActiveRecord::Migration
  def self.up
    create_table :employments do |t|
      t.string :employer
      t.string :title
      t.string :location
      t.datetime :start_date
      t.datetime :end_date
      t.references :contact

      t.timestamps
    end
  end

  def self.down
    drop_table :employments
  end
end
