module Mailer
  require 'net/smtp'
  require 'erb'
  
  def notify(logger, fname, uid, rcpt, days, sender)
    if days < 1
      logger.warn "#{uid}: Password has expired. Sending notification..."
      template = File.read(File.dirname(File.expand_path(__FILE__)) + '/../conf/expired.erb')
    else
      logger.warn "#{uid}: Password will expire in #{days} days. Sending notification..."
      template = File.read(File.dirname(File.expand_path(__FILE__)) + '/../conf/warn.erb')
    end

    message = ERB.new(template).result(binding)

    Net::SMTP.start('localhost') do |smtp|
     smtp.send_message message, sender, rcpt
    end
  end
end
