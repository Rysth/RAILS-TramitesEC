class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate_devise_api_token!
  before_action :require_admin

  # GET /api/v1/notifications/pending
  def pending
    procedures = Procedure.where(notification_sent: false)
                          .where.not(notification_scheduled_at: nil)
                          .includes(:customer, :procedure_type, :license)
                          .order(:notification_scheduled_at)

    render json: {
      total: procedures.count,
      due_now: procedures.where('notification_scheduled_at <= ?', Time.current).count,
      procedures: procedures.map { |p| notification_data(p) }
    }, status: :ok
  end

  # POST /api/v1/notifications/:procedure_id/send
  def send_notification
    procedure = Procedure.find(params[:procedure_id])

    unless procedure.primera_vez_license?
      render json: { error: 'Solo se pueden enviar notificaciones para licencias Primera Vez' }, status: :unprocessable_entity
      return
    end

    unless procedure.customer&.email.present?
      render json: { error: 'El cliente no tiene email registrado' }, status: :unprocessable_entity
      return
    end

    if procedure.notification_sent?
      render json: { error: 'La notificación ya fue enviada', sent_at: procedure.notification_sent_at }, status: :unprocessable_entity
      return
    end

    # Send notification synchronously
    SendProcedureNotificationJob.perform_now(procedure.id)
    procedure.reload

    render json: {
      message: 'Notificación enviada exitosamente',
      procedure: notification_data(procedure)
    }, status: :ok
  rescue StandardError => e
    render json: { error: "Error al enviar notificación: #{e.message}" }, status: :internal_server_error
  end

  # POST /api/v1/notifications/process
  def process_all
    ProcessPendingNotificationsJob.perform_later

    render json: {
      message: 'Procesamiento de notificaciones iniciado'
    }, status: :accepted
  end

  private

  def require_admin
    return if current_devise_api_user&.is_admin?

    render json: { error: 'Acceso denegado. Se requieren permisos de administrador.' }, status: :forbidden
  end

  def notification_data(procedure)
    {
      id: procedure.id,
      code: procedure.code,
      procedure_type: procedure.procedure_type&.name,
      customer: {
        name: "#{procedure.customer&.first_name} #{procedure.customer&.last_name}",
        email: procedure.customer&.email
      },
      notification_days: procedure.notification_days,
      notification_scheduled_at: procedure.notification_scheduled_at,
      notification_sent: procedure.notification_sent,
      notification_sent_at: procedure.notification_sent_at
    }
  end
end
