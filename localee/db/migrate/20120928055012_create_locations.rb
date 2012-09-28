class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :location_name
      t.string :gps_latitude
      t.string :gps_longitude

      t.timestamps
    end
  end
end
