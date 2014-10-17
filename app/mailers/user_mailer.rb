class UserMailer < ActionMailer::Base
  default from: "donotreply@crashmob.com"

  def notification(target_emails, message_to_send)

    mail(to: target_emails, subject: message_to_send)
  end
end
