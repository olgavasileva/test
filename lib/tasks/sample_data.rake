namespace :db do
  desc "Set up some analytics data"
  task sample_analytics: :environment do
    User.all.each do |u|
      (0..6).each do |d|
        date = Date.today - d.days

        a = DailyAnalytic.where(user_id:u, metric: :views, date:date).first_or_create!
        a.update_attribute :total, rand(150)

        a = DailyAnalytic.where(user_id:u, metric: :starts, date:date).first_or_create!
        a.update_attribute :total, rand(150)
      end
    end
  end
end

# require 'csv'
# require 'pp'

# namespace :db do
#   desc "Fill database with sample data"
#   task populate: :environment do
#     make_users
#     make_microposts
#     #make_relationships
#     make_devices
#     make_ownerships
#     make_categories
#     make_questions
#     make_choices
#     make_packs
#     make_inclusions
#   end
# end

# def make_users
#   twocents = User.create!(username:  "2cents",
#                         name:     "2cents",
#                         email:    "2cents@example.com",
#                         password: "2ctp2ctp",
#                         password_confirmation: "2ctp2ctp")

#   admin = User.create!(username: "jason",
#                        name:     "Jason Mueller",
#                        email:    "jason@sociallycs.com",
#                        password: "foobar69",
#                        password_confirmation: "foobar69",
#                        admin: true)
#   #99.times do |n|
#   #  username = "exampleuser_#{n+1}"
#   #  name  = Faker::Name.name
#   #  email = "example-#{n+1}@railstutorial.org"
#   #  password  = "password"
#   #  User.create!(username: username,
#   #               name:     name,
#   #               email:    email,
#   #               password: password,
#   #               password_confirmation: password)

#   #end
# end

# def make_microposts
#   users = User.all(limit: 6)
#   50.times do
#     content = Faker::Lorem.sentence(5)
#     users.each { |user| user.microposts.create!(content: content) }
#   end
# end

# def make_relationships
#   users = User.all
#   user  = users.first
#   followed_users = users[2..50]
#   followers      = users[3..40]
#   followed_users.each { |followed| user.follow!(followed) }
#   followers.each      { |follower| follower.follow!(user) }
# end

# def make_devices
#   10.times do |n|
#     udid = "NOT_A_REAL_UDID_#{n}"
#     device_type = "iPad3,2"
#     os_version = "7.0.3"
#     Device.create!( udid:         udid,
#                     device_type:  device_type,
#                     os_version:   os_version)
#   end
# end

# def make_ownerships
#   users = User.all
#   user = users.first
#   devices = Device.all
#   devices.each { |device| user.own!(device) }
# end

# def make_categories
#   filename = Rails.root + "app/csv/categories.csv"
#   CSV.foreach(filename, :headers => true) do |row|
#     pp row.to_hash
#     Category.create!(row.to_hash)
#   end
# end

# def make_questions
#   users = User.all
#   user = users.first

#   filename = Rails.root + "app/csv/questions.csv"
#   CSV.foreach(filename, :headers => true) do |row|
#     pp row.to_hash
#     question = user.questions.build(row.to_hash)
#     question.save
#     pp question.id
#   end
# end

# def make_choices
#   filename = Rails.root + "app/csv/choices.csv"
#   CSV.foreach(filename, :headers => true) do |row|
#     pp row.to_hash
#     Choice.create!(row.to_hash)
#   end
# end

# def make_packs
#   users = User.all
#   user = users.first

#   filename = Rails.root + "app/csv/packs.csv"
#   CSV.foreach(filename, :headers => true) do |row|
#     pp row.to_hash
#     pack = user.packs.build(row.to_hash)
#     pack.save
#   end
# end

# def make_inclusions
#   filename = Rails.root + "app/csv/inclusions.csv"
#   CSV.foreach(filename, :headers => true) do |row|
#     pp row.to_hash
#     Inclusion.create!(row.to_hash)
#   end
# end





