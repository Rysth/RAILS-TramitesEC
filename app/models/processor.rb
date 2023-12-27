class Processor < ApplicationRecord
  belongs_to :user
  has_many :customers, strict_loading: true

  validates :cedula, presence: true, uniqueness: { case_sensitive: false }
  validates :nombres, presence: true
  validates :apellidos, presence: true
  validates :celular, presence: true
  validates :active, inclusion: { in: [true, false] }
end
