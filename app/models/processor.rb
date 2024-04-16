class Processor < ApplicationRecord
  belongs_to :user
  has_many :customers, counter_cache: true
  has_many :procedures, counter_cache: true

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true, numericality: { only_integer: true }
  validates :active, inclusion: { in: [true, false] }
  validate :unique_name_combination

  before_validation :generate_code, on: :create

  def generate_code
    last_processor = Processor.last
    last_number = last_processor&.code&.match(/\d+/)&.[](0).to_i || 0
    self.code = "TR#{format('%07d', last_number + 1)}"
  end

  after_destroy :update_codes_after_deletion

  private

  def update_codes_after_deletion
    processors = Processor.order(:created_at)
    processors.each_with_index do |processor, index|
      new_code = "TR#{format('%07d', index + 1)}"
      processor.update(code: new_code)
    end
  end

  def unique_name_combination
    existing_processor = Processor.find_by(first_name:, last_name:)
    errors.add(:base, 'A Processor with the same first name and last name already exists.') if existing_processor && existing_processor != self
  end
end
