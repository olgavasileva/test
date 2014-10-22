class UserMailer < ActionMailer::Base
  default from: "donotreply@crashmob.com"

  def notification(target_emails, message_to_send)

    @message = message_to_send
    mail(to: target_emails, subject: "Check this out!!! Excellent App - Statisfy")
  end
end
