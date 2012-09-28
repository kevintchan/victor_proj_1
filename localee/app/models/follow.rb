class Follow < ActiveRecord::Base
  # attr_accessible :title, :body

  ### Associations 
  belongs_to :user
  belongs_to :location

  ### Validations

  # best implementation of composite primary key
  validates_uniqueness_of :user, :scope => :location

  validates_associated :user
  validates_associated :location

end
