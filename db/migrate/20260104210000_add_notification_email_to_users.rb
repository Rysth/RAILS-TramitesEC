class AddNotificationEmailToUsers < ActiveRecord::Migration[7.1]
  def change
    # Email where admin users will receive procedure notifications
    add_column :users, :notification_email, :string, default: nil
  end
end
