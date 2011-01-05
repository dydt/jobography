class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :title
      t.string :company
      t.float :pay
      t.timestamp :date
      t.string :source
      t.string :desc
      t.float :lat
      t.float :long
      t.string :state
      t.string :city
      t.string :zip

      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
