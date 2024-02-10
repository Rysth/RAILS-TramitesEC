class Status < ApplicationRecord
  has_many :procedures
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
end
