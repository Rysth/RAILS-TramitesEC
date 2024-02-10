class Payment < ApplicationRecord
  belongs_to :payment_type
  belongs_to :procedure

  validates :date, :value, presence: true
end
