class Status < ApplicationRecord
  validates :nombre, presence: true, uniqueness: { case_sensitive: true }
end
