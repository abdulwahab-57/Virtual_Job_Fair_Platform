class StudentProfile < ApplicationRecord
   # Associations
   belongs_to :user, inverse_of: :student_profile  # ✅ Add inverse_of
   validates :email_personal, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 100 }
   has_many :educations, dependent: :destroy
   has_many :projects, dependent: :destroy
   has_many :skills, dependent: :destroy
   has_many :activities_honors, dependent: :destroy
   has_many :interests, dependent: :destroy
   has_many :location_preferences, dependent: :destroy

   accepts_nested_attributes_for :educations, allow_destroy: true, reject_if: :all_blank
   accepts_nested_attributes_for :projects, allow_destroy: true, reject_if: :all_blank
   accepts_nested_attributes_for :skills, allow_destroy: true, reject_if: :all_blank
   accepts_nested_attributes_for :activities_honors, allow_destroy: true, reject_if: :all_blank
   accepts_nested_attributes_for :interests, allow_destroy: true, reject_if: :all_blank
   accepts_nested_attributes_for :location_preferences, allow_destroy: true, reject_if: :all_blank

   # Validations
   validates :email_personal, presence: true,  uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 100 }
   validates :phone_number, allow_blank: true,
             format: { with: /\A\+92\d{10}\z/ }
   validates :linkedin_url, allow_blank: true,
             format: { with: /\Ahttps?:\/\/(www\.)?linkedin\.com\/.*\z/ }
end
