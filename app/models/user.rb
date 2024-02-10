class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :api

  has_many :processors, strict_loading: true
  has_many :procedures, strict_loading: true
  has_many :customers, strict_loading: true
end
