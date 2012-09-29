class Location < ActiveRecord::Base
  # attr_accessible :title, :body

  ###Validations
  validates :name, :presence => true

  #TODO(kchan): include validation for bounds of GPS coordinates
  validates :latitude, :presence => true
  validates :longitude, :presence => true

  ### Associations
  has_many :posts


end
