class ProcedureSubType < ApplicationRecord
  # Associations
  belongs_to :procedure_type
  # Validations
  validates :name, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :procedure_type_id, presence: true
end
