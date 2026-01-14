class ProcedureType < ApplicationRecord
  has_many :procedures

  before_destroy :prevent_destroy_if_has_procedures

  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  validates :has_licenses, inclusion: { in: [true, false] }
  validates :archived, inclusion: { in: [true, false] }

  # Scopes for filtering
  scope :not_archived, -> { where(archived: false) }
  scope :archived_only, -> { where(archived: true) }

  private

  def prevent_destroy_if_has_procedures
    return unless procedures.exists?

    errors.add(:base, 'El tipo de trámite tiene trámites asociados y no se puede eliminar.')
    throw :abort
  end
end
