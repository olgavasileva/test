namespace :question do
  desc "Ensure all questions have a uuid"
  task uuid: :environment do
    Question.where(uuid:nil).each do |q|
      q.update_attribute :uuid, "Q"+UUID.new.generate.gsub(/-/, '')
    end
  end
end
