class Cliente < ApplicationRecord
  belongs_to :user

  validates :cedula, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 10 }
end
