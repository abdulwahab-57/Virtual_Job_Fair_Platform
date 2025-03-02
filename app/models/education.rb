class Education < ApplicationRecord
   # Associations
   belongs_to :student_profile

   # Validations
   # validates :student_profile_id, presence: true
   validates :institution_name, allow_blank: true, length: { maximum: 100 }
   validates :degree_title, allow_blank: true, length: { maximum: 100 }
   validates :field_of_study, allow_blank: true, length: { maximum: 100 }
   validates :graduation_year, allow_blank: true,
             numericality: {
               only_integer: true,
               greater_than: 1900,
               less_than_or_equal_to: -> { Date.current.year + 10 }
             }
end
