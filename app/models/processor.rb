class Processor < ApplicationRecord
  belongs_to :user
  has_many :customers

  validates :cedula, presence: true, uniqueness: { case_sensitive: false }, length: { is: 10 }
  validates :nombres, presence: true
  validates :apellidos, presence: true
  validates :celular, presence: true
  validates :active, inclusion: { in: [true, false] }
end
