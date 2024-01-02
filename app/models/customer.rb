class Customer < ApplicationRecord
  has_many :procedures
  belongs_to :processor, counter_cache: true

  validates :cedula, presence: true, uniqueness: { case_sensitive: false }
  validates :nombres, presence: true
  validates :apellidos, presence: true
  validates :celular, presence: true
  validates :direccion, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :active, inclusion: { in: [true, false] }
end
