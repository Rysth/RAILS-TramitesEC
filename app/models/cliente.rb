class Cliente < ApplicationRecord
  belongs_to :user
  belongs_to :role

  validates :cedula, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 10 }
  validates :nombres, presence: true
  validates :apellidos, presence: true
  validates :celular, presence: true
  validates :direccion, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }

  # Custom validation for user presence
  validate :user_presence
  # Custom validation for role presence
  validate :role_presence

  private

  def user_presence
    errors.add(:user, 'must be present') unless user.present?
  end

  def role_presence
    errors.add(:role, 'must be present') unless role.present?
  end
end
