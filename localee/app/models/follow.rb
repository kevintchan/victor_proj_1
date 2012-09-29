class Follow < ActiveRecord::Base
  # attr_accessible :title, :body

  # best implementation of composite primary key
  validates_uniqueness_of :location_id, :scope => :user_id

end
