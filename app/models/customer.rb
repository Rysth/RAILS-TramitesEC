class Customer < ApplicationRecord
  belongs_to :processor

  validates :cedula, presence: true, uniqueness: { case_sensitive: false }, length: { is: 10 }
  validates :nombres, presence: true
  validates :apellidos, presence: true
  validates :celular, presence: true
  validates :direccion, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :active, inclusion: { in: [true, false] }
end
