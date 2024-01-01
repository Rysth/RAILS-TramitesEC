class Type < ApplicationRecord
  has_many :licenses
  validates :nombre, presence: true, uniqueness: { case_sensitive: true }
end
