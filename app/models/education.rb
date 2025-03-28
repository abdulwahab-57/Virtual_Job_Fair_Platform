class Education < ApplicationRecord
   # Associations
   belongs_to :student_profile

   # Validations
   # validates :student_profile_id, presence: true
   validates :institution_name, allow_blank: true, length: { maximum: 80 }
   validates :degree, allow_blank: true, length: { maximum: 50 }
   validates :graduation_year, allow_blank: true,
             numericality: {
               only_integer: true,
               greater_than: 1900,
               less_than_or_equal_to: -> { Date.current.year + 10 }
             }
end
