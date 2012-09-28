class Location < ActiveRecord::Base
  # attr_accessible :title, :body

  ###Validations
  validates :loc_name, :presence => true

  #TODO(kchan): include validation for bounds of GPS coordinates
  validates :lat, :presence => true
  validates :lng, :presence => true

  ### Associations
  has_many :follows
  has_many :users, :through => follows
  has_many :posts
  

end
