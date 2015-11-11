require 'action_mailer'

ActionMailer::Base.delivery_method = :sendmail  # You can also use :smtp...
ActionMailer::Base.raise_delivery_errors = true

class Notifier < ActionMailer::Base
  default from: '"notifier" <donotreply@statisfy.co>'

  def deploy_notification(cap_vars)
    application_name = cap_vars.application.split('_')[0]
    mail(:to => cap_vars.notify_emails, :subject => "Application #{application_name} has been deployed in #{cap_vars.stage}") do |format|
      format.text do
        render :text => "Heyy girrrrl,\n\nThe application #{application_name} has been deployed in the #{cap_vars.stage} platform.\n\n#{cap_vars.release_notes}"
      end
    end
  end
end

namespace :deploy do
  desc "Email notifier"
  task :notify, :roles => :app, :except => { :no_release => true } do
    git_commits_range = "#{previous_revision.strip}..#{current_revision.strip}"
    git_log = `git log --pretty=oneline --abbrev-commit #{git_commits_range}`
    set :release_notes, git_log.blank? ? "No changes since last deploy." : "Last changes:\n" + git_log

    Notifier.deploy_notification(self).deliver
  end
end
