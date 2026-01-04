class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :api

  has_many :processors, strict_loading: true
  has_many :procedures, strict_loading: true
  has_many :customers, strict_loading: true
  has_many :suppliers, strict_loading: true

  # Validate notification_email format if present
  validates :notification_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # Scope to find admins with notification emails
  scope :notification_recipients, -> {
    where(is_admin: true, active: true)
      .where.not(notification_email: [nil, ''])
  }

  # Class method to get all notification emails for admins
  def self.admin_notification_emails
    notification_recipients.pluck(:notification_email)
  end
end
