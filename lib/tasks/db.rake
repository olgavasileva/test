namespace :db do
  desc "Remove data in preparation for a seed data"
  task unseed: :environment do
    CannedQuestionImage.destroy_all
    CannedChoiceImage.destroy_all
    CannedOrderChoiceImage.destroy_all

    Category.destroy_all
  end
end
