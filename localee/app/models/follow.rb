class Follow < ActiveRecord::Base
  # attr_accessible :title, :body

  ### Associations
  belongs_to :user

  ### Validations

  # best implementation of composite primary key
  validates_uniqueness_of :location_id, :scope => :user_id

  validates_associated :user

end
