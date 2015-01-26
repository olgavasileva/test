namespace :db do
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
