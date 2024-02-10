class Procedure < ApplicationRecord
  belongs_to :user
  belongs_to :customer
  belongs_to :procedure_type, class_name: "ProcedureType"
  belongs_to :status
  belongs_to :license, optional: true
  belongs_to :processor, optional: true

  has_many :payments

  validates :code, presence: true, uniqueness: true
  validates :date, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :cost_pending, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :profit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :profit_pending, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :is_paid, inclusion: { in: [true, false] }

  validates :user, :customer, :procedure_type, :status, presence: true

  before_validation :generate_code, on: :create
  before_validation :set_date, on: :create

  def generate_code
    last_procedure = Procedure.last
    last_number = last_procedure&.code&.match(/\d+/)&.[](0).to_i || 0
    self.code = "TEC#{format('%07d', last_number + 1)}"
  end

  def set_date
    self.date = Time.zone.now
  end
end
