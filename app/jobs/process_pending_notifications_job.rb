# Job to check and process all pending notifications
# This job should be scheduled to run periodically (e.g., every hour via cron or sidekiq-scheduler)
class ProcessPendingNotificationsJob < ApplicationJob
  queue_as :notifications

  def perform
    Rails.logger.info "Processing pending notifications at #{Time.current}"

    procedures = Procedure.pending_notifications
                          .includes(:customer, :procedure_type, :license, :course)

    Rails.logger.info "Found #{procedures.count} procedures with pending notifications"

    procedures.find_each do |procedure|
      # Enqueue individual notification job
      SendProcedureNotificationJob.perform_later(procedure.id)
    end

    Rails.logger.info "Finished enqueueing pending notification jobs"
  end
end
