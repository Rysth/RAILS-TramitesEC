class Processor < ApplicationRecord
  belongs_to :user
  has_many :procedures
  has_many :customers, counter_cache: true

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :nombres, presence: true
  validates :apellidos, presence: true
  validates :celular, presence: true, numericality: { only_integer: true }
  validates :active, inclusion: { in: [true, false] }

  before_validation :generate_code, on: :create

  def generate_code
    last_processor = Processor.last
    last_number = last_processor&.code&.match(/\d+/)&.[](0).to_i || 0
    self.code = "TR#{format('%07d', last_number + 1)}"
  end
end
