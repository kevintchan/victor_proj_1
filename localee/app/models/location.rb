class Location < ActiveRecord::Base
  # attr_accessible :title, :body

  #Validations
  validates :location_name, :presence => true
  validates :gps_latitude, :presence => true
  validates :gps_longitutde, :presence => true

end
