class Processor < ApplicationRecord
  belongs_to :user
  has_many :procedures
  has_many :customers, counter_cache: true

  validates :codigo, presence: true, uniqueness: { case_sensitive: false }
  validates :nombres, presence: true
  validates :apellidos, presence: true
  validates :celular, presence: true
  validates :active, inclusion: { in: [true, false] }

  before_validation :generate_codigo, on: :create

  def generate_codigo
    last_processor = Processor.last
    last_number = last_processor&.codigo&.match(/\d+/)&.[](0).to_i || 0
    self.codigo = "TR#{format('%07d', last_number + 1)}"
  end
end
