# Job to send a single procedure notification
class SendProcedureNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(procedure_id)
    procedure = Procedure.find_by(id: procedure_id)
    return unless procedure
    return if procedure.notification_sent?
    return unless procedure.customer&.email.present?

    # Send the reminder email to customer
    ProcedureMailer.license_reminder(procedure).deliver_now

    # Send admin notification
    ProcedureMailer.admin_notification(procedure).deliver_now

    # Mark as sent
    procedure.mark_notification_sent!

    Rails.logger.info "Notification sent for procedure #{procedure.code} to #{procedure.customer.email}"
  rescue StandardError => e
    Rails.logger.error "Failed to send notification for procedure #{procedure_id}: #{e.message}"
    raise e # Re-raise to trigger retry
  end
end
