class LicenseType < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
end
