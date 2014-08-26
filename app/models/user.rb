class User < ActiveRecord::Base
  before_save { email.downcase! } # can also use { self.email = email.downcase }
  before_create :create_remember_token

  validates :name, presence: true, length: { maximum: 50 }
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i  #this one allows for invalid "foo@bar..com" double dots!
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  #presence validations for the password and its confirmations are automatically added by "has_secure_password"

  has_secure_password

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s) 
    # the "to_s" method is so we can handle nil tokens
    # this shouldn't happen in browsers but sometimes happens in tests. 

  end 

  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end   
end
