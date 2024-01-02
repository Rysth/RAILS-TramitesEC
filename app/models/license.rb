class License < ApplicationRecord
  has_many :procedures
  belongs_to :type
  validates :nombre, presence: true, uniqueness: { case_sensitive: true }
end
