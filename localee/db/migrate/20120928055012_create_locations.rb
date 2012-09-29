class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :loc_name
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
