class ProcedureType < ApplicationRecord
  has_many :procedures

  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  validates :has_licenses, inclusion: { in: [true, false] }
end
