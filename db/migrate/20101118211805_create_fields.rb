class CreateFields < ActiveRecord::Migration
  def self.up
    create_table :fields do |t|
      t.string :ftype
      t.integer :fstate
      t.integer :x
      t.integer :y
      t.references :user
      t.timestamps
    end
  end

  def self.down
    drop_table :fields
  end
end
