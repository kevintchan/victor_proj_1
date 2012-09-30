class Location < ActiveRecord::Base
  # attr_accessible :title, :body

  ###Validations
  validates :name, :presence => true

  #ADDED: included validation for bounds of GPS coordinates, can't test since VM isn't working...
  validates :latitude, numericality: {
   	    greater_than_or_equal_to: -89.999, less_than_or_equal_to: 89.999
  }, :presence => true

  validates :longitude, numericality: {
  	    greater_than_or_equal_to: -179.999, less_than_or_equal_to: 179.999
  }, :presence => true

  ### Associations
  has_many :posts


end
