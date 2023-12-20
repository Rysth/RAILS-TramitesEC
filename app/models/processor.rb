class Processor < ApplicationRecord
  has_many :customers

  validates :cedula, presence: true, uniqueness: { case_sensitive: false }
  validates :nombres, presence: true
  validates :apellidos, presence: true
  validates :celular, presence: true
  validates :active, inclusion: { in: [true, false] }
end
