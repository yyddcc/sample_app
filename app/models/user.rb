class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id", 
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower # :source here could be omitted
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: {case_sensitive: false}
  #has_secure_password includes a seperate presence validation on object creation.
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  #Return the hash digest of the goven string.
  def User.digest(string)
  	cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # return a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # remember a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # return ture if the given token matches the digest.
  def authenticated?(attribute, token) 
    digest = self.send("#{attribute}_digest") #self could be omitted because we are in the user model
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # forget a user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  # self. is optional inside the model
  def activate
    self.update_attribute(:activated, true)
    self.update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token # self. of variable can't be omitted in assignment
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Return true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago # < reads less than
  end

  # Defines a proto-feed.
  # See "Following users" for the full implementation.
  def feed
    # The ? ensures that id is properly escaped before being included in the underlying 
    # SQL query, thereby avoiding a serious security hole called SQL injection.
    # The following_ids pulls all the followed users’ ids into memory, and creates an array the full length of the followed users array
    # Micropost.where("user_id IN (?) or user_id = ?", following_ids, id)

    # The condition checks inclusion in a set, and SQL is optimized for set operations.
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private
    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
