class Education < ApplicationRecord
   # Associations
   belongs_to :student_profile

   # Validations
   validates :student_profile_id, presence: true
   validates :institution_name, presence: true, length: { maximum: 100 }
   validates :degree_title, presence: true, length: { maximum: 100 }
   validates :field_of_study, presence: true, length: { maximum: 100 }
   validates :graduation_year, presence: true,
             numericality: {
               only_integer: true,
               greater_than: 1900,
               less_than_or_equal_to: -> { Date.current.year + 10 }
             }
end
