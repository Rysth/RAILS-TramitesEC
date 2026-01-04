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
  def admin_notification(procedure)
    @procedure = procedure
    @customer = procedure.customer

    mail(
      to: 'support@rysthdesign.com',
      subject: "Notificación enviada - Trámite #{procedure.code}"
    )
  end
end
