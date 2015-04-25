class RespondentObserver < ActiveRecord::Observer
  def after_create respondent
    # New users get all the public questions for their feed
    update_feed! respondent if respondent.auto_feed?

    # Add a statisfy demographic record if they provided us with some data
    update_demographics! respondent
  end

  def after_update respondent
    update_demographics! respondent
  end

  private

    def update_feed! respondent
      # Seed the feed synchronously (limit the number so we don't take too long)
      respondent.append_questions_to_feed! (ENV['NEW_USER_FEED_SEED_SIZE'] || 100).to_i
    end

    def update_demographics! respondent
      if respondent.age.present? || respondent.gender.present? || respondent.current_sign_in_ip.present?
        DataProvider.where(name:'statisfy').first_or_create
        d = respondent.demographics.statisfy.first_or_create
        d.age = respondent.age
        d.gender = respondent.gender
        d.ip_address = respondent.current_sign_in_ip
        d.save!
      end
    end
end