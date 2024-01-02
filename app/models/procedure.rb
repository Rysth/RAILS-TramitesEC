class Procedure < ApplicationRecord
  belongs_to :processor
  belongs_to :customer
  belongs_to :user
  belongs_to :type
  belongs_to :license
  belongs_to :status

  validates :codigo, presence: true, uniqueness: true
  validates :fecha, presence: true
  validates :valor, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valor_pendiente, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :ganancia, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :ganancia_pendiente, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :user, :processor, :customer, :type, :license, :status, presence: true

  before_validation :generate_codigo, on: :create
  before_validation :set_fecha, on: :create

  def generate_codigo
    last_procedure = Procedure.order(created_at: :desc).first
    last_number = last_procedure&.codigo&.match(/\d+/)&.to_i || 0
    self.codigo = "TEC#{format('%07d', last_number + 1)}"
  end

  def set_fecha
    self.fecha = Time.zone.now
  end
end
