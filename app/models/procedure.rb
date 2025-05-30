class Procedure < ApplicationRecord
  belongs_to :user
  belongs_to :customer, optional: true
  belongs_to :procedure_type, class_name: 'ProcedureType'
  belongs_to :status
  belongs_to :license, optional: true
  belongs_to :processor, optional: true
  belongs_to :supplier, optional: true
  belongs_to :agency, optional: true

  has_many :payments, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :date, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_pending, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :profit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :profit_pending, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :is_paid, inclusion: { in: [true, false] }

  validates :user, :procedure_type, :status, presence: true

  before_validation :generate_code, on: :create
  before_validation :set_date, on: :create

  validate :plate_uniqueness_by_type_and_year, on: %i[create update]

  def generate_code
    last_procedure = Procedure.last
    last_number = last_procedure&.code&.match(/\d+/)&.[](0).to_i || 0
    self.code = "TEC#{format('%07d', last_number + 1)}"
  end

  def set_date
    self.date = Time.zone.now
  end

  before_save :update_is_paid_status

  def update_is_paid_status
    self.is_paid = true if cost_pending.zero? && profit_pending.zero?
  end

  def plate_uniqueness_by_type_and_year
    return if plate.blank? # Skip if no plate is provided
    return if procedure_type&.has_licenses? # Skip validation if procedure type requires licenses (only for vehicular)

    # Get the year from the created_at or current year if creating
    procedure_year = created_at&.year || Date.current.year

    # Look for existing procedures with same plate, procedure type, and year
    existing_procedure = Procedure.joins(:procedure_type)
                                  .where(plate: plate, procedure_type_id: procedure_type_id)
                                  .where('EXTRACT(YEAR FROM procedures.created_at) = ?', procedure_year)
                                  .where.not(id: id) # Exclude current record for updates

    if existing_procedure.exists?
      existing_record = existing_procedure.first
      errors.add(:plate, "Ya existe un trámite con esta placa en el año #{procedure_year}. Código del trámite existente: #{existing_record.code}")
    end
  end
end
