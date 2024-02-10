class License < ApplicationRecord
  # Associations
  belongs_to :license_type
  
  # Validations
  validates :name, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :license_type_id, presence: true
end
