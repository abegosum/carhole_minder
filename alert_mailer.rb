require_relative 'constants'
require 'net/smtp'
require 'date'

class AlertMailer

  
  def self.send_door_long_opened_alert(timestamp_opened)
    time_opened = Time.at(timestamp_opened).to_datetime
    message = <<~EOF
      Subject: Garage Door Open too Long

      Your garage door has been open since #{time_opened.strftime("%l:%M %P on %-m/%-d/%Y")}.

      If the timer is disabled and this is expected, you may ignore this message.  Otherwise, please check the timer on the door and any obstructions.

      Thank you,
      - Carhole Garage Minder
    EOF

    Net::SMTP.start('localhost') do |smtp|
      smtp.send_message(message, FROM_EMAIL, ALERT_EMAILS)
    end
  end

end
