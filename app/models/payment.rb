class Payment < ApplicationRecord
  belongs_to :payment_type
  belongs_to :procedure

  validates :date, :value, presence: true

  before_validation :set_date, on: :create

  private

  def set_date
    self.date ||= Time.zone.today
  end
end
