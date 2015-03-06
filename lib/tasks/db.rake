namespace :db do

  desc 'Backfill source field for responses'
  task backfill_response_source: :environment do
    # Users with only one instance whose device is from Apple have answered all of their questions on their iPhone
    User.joins(instances: :device).where(devices: {manufacturer: 'Apple Inc.'}).find_each do |user|
      user.responses.where(source:nil).update_all source:'ios' if u.devices.where.not(manufacturer: 'Apple Inc.').empty?
    end

    # Questions that are survey_only were answered as part of an embeddable unit
    Response.joins(:question).where(questions: {state: 'survey_only'}).update_all source:'embeddable'

    # Of the rest, those with any quantcast data are from the web
    Response.joins(demographics: :data_provider).where(source: nil).where(data_providers: {name: 'quantcast'}).update_all source: 'web'

    # Assume the rest are iOS?
    # Response.where(source: nil).update_all source: 'ios'
  end

  desc 'Create demographic data from user gender and age'
  task demographics: :environment do
    ActiveRecord::Base.transaction do
      Respondent.where("birthdate is not NULL OR gender is not NULL OR current_sign_in_ip is not NULL").find_each do |r|
        provider = DataProvider.where(name:'statisfy').first_or_create
        d = r.demographics.statisfy.first_or_create
        d.age = r.age
        d.gender = r.gender
        d.ip_address = r.current_sign_in_ip
        d.save!
      end
    end
  end

  task summarize_demographics: :environment do
    Respondent.find_each do |respondent|
      DemographicSummary.where(respondent: respondent).first_or_create.calculate!
    end
  end

  task categories_to_tags: :environment do
    Question.find_each do |q|
      q.tag_list.add q.category.name
      q.save
    end
  end

  desc 'Remove data in preparation for a seed data'
  task unseed: :environment do
    CannedQuestionImage.destroy_all
    CannedChoiceImage.destroy_all
    CannedOrderChoiceImage.destroy_all

    Category.destroy_all
  end
  desc 'remove all spam comments'
  task clear_spam: :environment do |t|
    puts t
    comments = Comment.where('body REGEXP \'(ht|f)tps?:\/\/[\w]*\.[\w]*\'')
    if comments.length > 0
      puts "These comments include URLs and will be removed: [#{comments.map(&:id).join(',')}]"
      comments.each(&:destroy)
    else
      puts 'There are not any comments with URLs'
    end
  end
  namespace :clear_spam do
    task dry: :environment do |t|
      puts t
      comments_ids = Comment.where('body REGEXP \'(ht|f)tps?:\/\/[\w]*\.[\w]*\'').pluck(:id)
      if comments_ids.length > 0
        puts "These comments include URLs: [#{comments_ids.join(',')}]"
      else
        puts 'There are not any comments with URLs'
      end
    end
  end
  def duplicating_responses(question_ids)
    r1 = Arel::Table.new(:responses, as: 'r1')
    r2 = Arel::Table.new(:responses, as: 'r2')
    r3 = r1.join(r2).on(
        r1[:user_id].eq(r2[:user_id]).and(
            r1[:question_id].eq(r2[:question_id]).and(
                r1[:choice_id].eq(r2[:choice_id])
            )
        )
    ).where(r1[:question_id].in(question_ids)).project(r1[:id])
    Response.where(Response.arel_table[:id].in(r3))
  end
  task :clear_duplicate_answers, [:ids] => [:environment] do |_, args|
    question_ids = args[:ids].split ' '
    responses = duplicating_responses question_ids
    if responses.length > 0
      current_id = nil
      responses.each do |response|
        if response.question_id != current_id
          current_id = response.question_id
        else
          response.destroy
        end
      end
    end
  end
  namespace :clear_duplicate_answers do
    task :dry, [:ids] => [:environment] do |_, args|
      question_ids = args[:ids].split ' '
      responses = duplicating_responses question_ids
      question_ids.each do |question_id|
        duplicate_response_count = responses.where(question_id: question_id).count
        puts "Question##{question_id} has #{duplicate_response_count} duplicating answers"
      end
    end
  end
end
