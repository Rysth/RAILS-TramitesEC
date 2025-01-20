class Agency < ApplicationRecord
  # Callbacks
  before_validation :generate_code, on: :create

  # Validations
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :has_licenses, inclusion: { in: [true, false] }

  private

  def generate_code
    last_agency = Agency.last
    last_number = last_agency&.code&.match(/\d+/)&.[](0).to_i || 0
    self.code = "AGC#{format('%04d', last_number + 1)}"
  end
end
