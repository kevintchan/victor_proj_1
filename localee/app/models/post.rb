class Post < ActiveRecord::Base
  # attr_accessible :title, :body

  ### Associations
  belongs_to :location

  ### Validations
  validates :text, :presence => true, :length => {:maximum => 200}
  validates_associated :user
  validates_associated :location

end
