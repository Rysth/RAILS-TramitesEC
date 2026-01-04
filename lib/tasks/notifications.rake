namespace :notifications do
  desc 'Process all pending procedure notifications'
  task process: :environment do
    puts "Processing pending notifications at #{Time.current}"

    procedures = Procedure.pending_notifications
                          .includes(:customer, :procedure_type, :license, :course)

    puts "Found #{procedures.count} procedures with pending notifications"

    procedures.find_each do |procedure|
      puts "Sending notification for procedure #{procedure.code}..."
      SendProcedureNotificationJob.perform_now(procedure.id)
    end

    puts 'Finished processing notifications'
  end

  desc 'Test sending a notification email for a specific procedure'
  task :test, [:procedure_id] => :environment do |_t, args|
    procedure_id = args[:procedure_id]

    unless procedure_id
      puts 'Usage: rails notifications:test[procedure_id]'
      exit 1
    end

    procedure = Procedure.find_by(id: procedure_id)

    unless procedure
      puts "Procedure with ID #{procedure_id} not found"
      exit 1
    end

    puts "Sending test notification for procedure #{procedure.code}..."
    puts "Customer: #{procedure.customer&.first_name} #{procedure.customer&.last_name}"
    puts "Email: #{procedure.customer&.email}"

    if procedure.customer&.email.present?
      ProcedureMailer.license_reminder(procedure).deliver_now
      puts 'Test email sent successfully!'
    else
      puts 'Error: Customer has no email address'
    end
  end

  desc 'List all procedures with scheduled notifications'
  task list: :environment do
    puts "\n=== Scheduled Notifications ===\n\n"

    pending = Procedure.where(notification_sent: false)
                       .where.not(notification_scheduled_at: nil)
                       .includes(:customer, :procedure_type)
                       .order(:notification_scheduled_at)

    if pending.empty?
      puts 'No pending notifications found.'
    else
      pending.each do |procedure|
        status = procedure.notification_scheduled_at <= Time.current ? '⏰ DUE' : '📅 SCHEDULED'
        puts "#{status} | #{procedure.code} | #{procedure.procedure_type&.name}"
        puts "   Customer: #{procedure.customer&.first_name} #{procedure.customer&.last_name}"
        puts "   Email: #{procedure.customer&.email || 'N/A'}"
        puts "   Scheduled: #{procedure.notification_scheduled_at.strftime('%Y-%m-%d %H:%M')}"
        puts "   Days: #{procedure.notification_days}"
        puts ''
      end
    end

    puts "\n=== Sent Notifications ===\n\n"

    sent = Procedure.where(notification_sent: true)
                    .includes(:customer, :procedure_type)
                    .order(notification_sent_at: :desc)
                    .limit(10)

    if sent.empty?
      puts 'No sent notifications found.'
    else
      sent.each do |procedure|
        puts "✅ #{procedure.code} | #{procedure.procedure_type&.name}"
        puts "   Customer: #{procedure.customer&.first_name} #{procedure.customer&.last_name}"
        puts "   Sent: #{procedure.notification_sent_at&.strftime('%Y-%m-%d %H:%M')}"
        puts ''
      end
    end
  end
end
