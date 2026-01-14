class Procedure < ApplicationRecord
  belongs_to :user
  belongs_to :customer, optional: true
  belongs_to :procedure_type, class_name: 'ProcedureType'
  belongs_to :status
  belongs_to :license, optional: true
  belongs_to :processor, optional: true
  belongs_to :supplier, optional: true
  belongs_to :agency, optional: true
  belongs_to :course, optional: true
  belongs_to :school, optional: true

  has_many :payments, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :date, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_pending, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :profit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :profit_pending, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :is_paid, inclusion: { in: [true, false] }
  validates :notification_days, inclusion: { in: [1, 7, 15, 30, nil] }

  validates :user, :procedure_type, :status, presence: true

  before_validation :generate_code, on: :create
  before_validation :set_date, on: :create
  before_save :schedule_notification, if: :should_schedule_notification?

  # Notification duration options (in days)
  NOTIFICATION_OPTIONS = {
    1 => '1 día',
    7 => '7 días',
    15 => '15 días',
    30 => '1 mes'
  }.freeze

  # Scope to find procedures that need notification
  scope :pending_notifications, -> {
    where(notification_sent: false)
      .where.not(notification_scheduled_at: nil)
      .where('notification_scheduled_at <= ?', Time.current)
  }

  # Check if this is a "Primera Vez" license procedure
  def primera_vez_license?
    procedure_type&.has_licenses? && procedure_type&.name == 'Primera Vez'
  end

  # Schedule notification based on notification_days
  def schedule_notification
    return unless notification_days.present? && primera_vez_license?

    self.notification_scheduled_at = Time.current + notification_days.days
    self.notification_sent = false
    self.notification_sent_at = nil
  end

  # Determine if we should schedule a notification
  def should_schedule_notification?
    notification_days_changed? && notification_days.present? && primera_vez_license?
  end

  # Mark notification as sent
  def mark_notification_sent!
    update!(notification_sent: true, notification_sent_at: Time.current)
  end

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
