class RespondentObserver < ActiveRecord::Observer
  def after_create respondent
    #
    # New users get all the public questions for their feed
    #

    # Seed the feed synchronously (limit the number so we don't take too long)
    respondent.append_questions_to_feed! (ENV['NEW_USER_FEED_SEED_SIZE'] || 100).to_i

    # Do the rest in a background thread
    Resque.enqueue BuildRespondentFeed, respondent.id


    #
    # Demographics
    #

    # Add a statisfy demographic record if they provided us with some data
    if respondent.age.present? || respondent.gender.present?
      DataProvider.where(name:'statisfy').first_or_create
      d = respondent.demographics.statisfy.first_or_create
      d.age = respondent.age
      d.gender = respondent.gender
      d.save!
    end

  end
end