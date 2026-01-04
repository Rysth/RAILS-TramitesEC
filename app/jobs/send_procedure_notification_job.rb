# Job to send a single procedure notification
class SendProcedureNotificationJob < ApplicationJob
  queue_as :notifications

  def perform(procedure_id)
    procedure = Procedure.find_by(id: procedure_id)
    return unless procedure
    return if procedure.notification_sent?

    mail = ProcedureMailer.admin_notification(procedure)
    return unless mail

    # Send admin notification only (no customer delivery for now)
    mail.deliver_now

    # Mark as sent
    procedure.mark_notification_sent!

    Rails.logger.info "Admin notification sent for procedure #{procedure.code}"
  rescue StandardError => e
    Rails.logger.error "Failed to send notification for procedure #{procedure_id}: #{e.message}"
    raise e # Re-raise to trigger retry
  end
end
