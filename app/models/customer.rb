class Customer < ApplicationRecord
  belongs_to :user
  belongs_to :processor, optional: true, counter_cache: true
  has_many :procedures

  validates :identification, presence: true, uniqueness: { case_sensitive: false }, numericality: { only_integer: true }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true, numericality: { only_integer: true }
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :is_direct, inclusion: { in: [true, false] }
  validates :active, inclusion: { in: [true, false] }
end
