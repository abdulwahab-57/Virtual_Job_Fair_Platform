class Education < ApplicationRecord
  belongs_to :student_profile

  DEGREE_OPTIONS = [
    "BS (Computer Science)",
    "BS (Artificial Intelligence)",
    "BS (Software Engineering)",
    "BS (Business Analytics)",
    "BS (Electrical Engineering)",
    "Bachelor of Business Administration"
  ].freeze

  validates :institution_name, allow_blank: true, length: { maximum: 80 }
  validates :degree, allow_blank: true, length: { maximum: 50 }
  validates :graduation_year, allow_blank: true,
            numericality: {
              only_integer: true,
              greater_than: 1900,
              less_than_or_equal_to: -> { Date.current.year + 10 }
            }

  def self.ransackable_attributes(auth_object = nil)
    %w[degree graduation_year]
  end

  def self.available_graduation_years
    where(degree: DEGREE_OPTIONS)
      .where.not(graduation_year: nil)
      .distinct
      .pluck(:graduation_year)
      .sort
      .reverse
  end
end
