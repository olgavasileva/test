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
end
