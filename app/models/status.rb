class Status < ApplicationRecord
  has_many :procedures
  validates :nombre, presence: true, uniqueness: { case_sensitive: true }
end
