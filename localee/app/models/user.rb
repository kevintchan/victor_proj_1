class User < ActiveRecord::Base

  ################################
  #  DO NOT MODIFY THIS SECTION  #
  ################################

  # Use Rails internal password digesting
  has_secure_password

  ### Validations
  validates :name, :presence => true
  validates :email, :presence => true, :uniqueness => true
  validates :password_digest, :presence => true, :on => :create, :length => {:minimum => 5}

  ############################################
  #  TODO: you may optionally add code here  #
  ############################################

  ### Associations
  has_many :follows

  def to_hash
    {
      :id => self.id,
      :name => self.name,
      :email => self.email
    }
  end

end
