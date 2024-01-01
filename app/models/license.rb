class License < ApplicationRecord
  belongs_to :type
  validates :nombre, presence: true, uniqueness: { case_sensitive: true }
end
