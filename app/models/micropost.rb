class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader # defined in picture_uploader.rb
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size # Custom validation

  private
  	#validates the size of an uploaded picture.
  	def picture_size
  	  if picture.size > 5.megabytes
  	  	errors.add(:picture, "should be less than 5MB")
  	  end
  	end
end
