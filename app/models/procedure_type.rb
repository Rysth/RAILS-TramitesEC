class ProcedureType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  validates :has_children, inclusion: { in: [true, false] }
end
