class ProcedureMailer < ApplicationMailer
  default from: 'support@rysthdesign.com'

  def license_reminder(procedure)
    @procedure = procedure
    @customer = procedure.customer
    @license = procedure.license
    @course = procedure.course
    @procedure_type = procedure.procedure_type

    return unless @customer&.email.present?

    mail(
      to: @customer.email,
      subject: "Recordatorio: Licencia #{@license&.name || 'Primera Vez'} - TrámitesEC"
    )
  end

  # Admin notification when a procedure reminder is sent
  # Sends to all admin users who have notification_email configured
  def admin_notification(procedure)
    @procedure = procedure
    @customer = procedure.customer

    # Get all admin notification emails
    admin_emails = User.admin_notification_emails

    # Return if no admin has configured notification email
    return if admin_emails.empty?

    mail(
      to: admin_emails,
      subject: "Notificación enviada - Trámite #{procedure.code}"
    )
  end
end
