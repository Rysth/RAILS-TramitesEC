class Procedure < ApplicationRecord
  belongs_to :processor
  belongs_to :customer
  belongs_to :user
  belongs_to :license
  belongs_to :status

  validates :codigo, presence: true, uniqueness: true
  validates :fecha, presence: true
  validates :valor, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valor_pendiente, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :ganancia, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :ganancia_pendiente, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :processor, :customer, :user, :license, :status, presence: true
end
