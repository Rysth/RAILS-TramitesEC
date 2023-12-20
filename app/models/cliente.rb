class Cliente < ApplicationRecord
  validates :cedula, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 10 }
  validates :nombres, presence: true
  validates :apellidos, presence: true
  validates :celular, presence: true
  validates :direccion, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :active, inclusion: { in: [true, false] }
end
