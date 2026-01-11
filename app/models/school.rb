class School < ApplicationRecord
  has_many :procedures, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
end
