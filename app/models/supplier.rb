class Supplier < ApplicationRecord
   # Associations
   belongs_to :user

   # Validations
   validates :identification, presence: true, uniqueness: true
   validates :name, presence: true
   validates :phone, presence: true
   validates :user, presence: true
 
   # Scopes
   scope :active, -> { where(active: true) }
end
