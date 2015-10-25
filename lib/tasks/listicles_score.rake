namespace :listicle do
  desc 'Ensure score store is valid'
  task score: :environment do
    ActiveRecord::Base.transaction do
      begin
        question_user_responses = {}
        ListicleQuestion.all.find_each do |question|
          question_user_responses[question.id] = {}
          question.responses.find_each do |response|
            question_user_responses[question.id][response.user_id] ||= []
            question_user_responses[question.id][response.user_id] << response
          end
          question_user_responses[question.id].each do |user_id, responses|
            question_user_responses[question.id][user_id] = responses.sort_by { |response| response.created_at }.reverse.take(2)
            last_responses = question_user_responses[question.id][user_id]
            if last_responses.length == 1
              question_user_responses[question.id][user_id] = last_responses.first.is_up ? 1 : -1
            elsif last_responses.length == 2
              question_user_responses[question.id][user_id] = last_responses.map { |r| r.is_up ? 1 : -1 }.sum / 2
            end
          end
        end

        question_user_responses.each do |question_id, user_responses|
          question = ListicleQuestion.find(question_id)
          question.responses.destroy_all
          next if user_responses.empty?
          user_responses.each do |user_id, score|
            ListicleResponse.create(user_id: user_id, score: score, question_id: question_id)
          end
        end
      rescue Exception => e
        puts e, question_user_responses
        raise ActiveRecord::Rollback
      end

    end
  end
end