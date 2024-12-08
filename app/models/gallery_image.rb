class GalleryImage < ApplicationRecord
  # Associations
  belongs_to :recruiter_profile

  # Validations
  validates :recruiter_profile_id, presence: true
  validates :image_url, presence: true
end
