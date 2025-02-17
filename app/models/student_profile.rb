class StudentProfile < ApplicationRecord
   # Associations
   belongs_to :user, inverse_of: :student_profile  # ✅ Add inverse_of
   has_many :educations, dependent: :destroy
   has_many :projects, dependent: :destroy
   has_many :skills, dependent: :destroy
   has_many :activities_honors, dependent: :destroy
   has_many :interests, dependent: :destroy
   has_many :location_preferences, dependent: :destroy


   # Validations
   # validates :user_id, presence: true, uniqueness: true
   validates :email_personal, allow_blank: true,
             format: { with: URI::MailTo::EMAIL_REGEXP },
             length: { maximum: 100 }
   validates :phone_number, allow_blank: true,
             format: { with: /\A\+?[\d\s-]{10,20}\z/ }
   validates :linkedin_url, allow_blank: true,
             format: { with: /\Ahttps?:\/\/(www\.)?linkedin\.com\/.*\z/ }
end
