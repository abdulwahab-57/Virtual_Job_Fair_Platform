class SearchUser < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :query, presence: true, length: { minimum: 2, maximum: 100 }
end
