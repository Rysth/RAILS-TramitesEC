class AddNotificationFieldsToProcedures < ActiveRecord::Migration[7.1]
  def change
    # Notification duration in days (1, 7, 15, 30)
    add_column :procedures, :notification_days, :integer, default: nil
    # When to send the notification
    add_column :procedures, :notification_scheduled_at, :datetime, default: nil
    # Whether notification was already sent
    add_column :procedures, :notification_sent, :boolean, default: false
    # When the notification was sent
    add_column :procedures, :notification_sent_at, :datetime, default: nil

    add_index :procedures, :notification_scheduled_at
    add_index :procedures, :notification_sent
  end
end
