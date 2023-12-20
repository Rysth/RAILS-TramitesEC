class Role < ApplicationRecord
  has_many :clientes

  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }
end
