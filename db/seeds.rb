# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#
# Users
#

user = User.where(username:'crashmob').first_or_create!(name:"Question Master",email:'question-master@crashmob.com',password:"dirty socks",password_confirmation:"dirty socks")

#
# Categories
#
def seed_image filename
  File.join "db","seeds",filename
end

business = Category.where(name:"Business").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "business-icon.png"))
values = Category.where(name:"Values").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "values-icon.png"))
sports = Category.where(name:"Sports").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "sports-icon.png"))


#
# Questions
#

q = ChoiceQuestion.where(title:"How much should be spent on meteor-strike prevention?").first_or_create!(rotate:false,category:business,user:user)
q.choices.where(title:"About $1").first_or_create!
q.choices.where(title:"Up to $10").first_or_create!
q.choices.where(title:"Up to $100").first_or_create!
q.choices.where(title:"Up to $1,000").first_or_create!
q.choices.where(title:"Over $1,000").first_or_create!

q = ChoiceQuestion.where(title:"Who’s coffee do you prefer?").first_or_create!(rotate:true,category:values,user:user)
q.choices.where(title:"Starbucks").first_or_create!(image:open(seed_image("starbucks.jpg")))
q.choices.where(title:"Einstein's").first_or_create!(image:open(seed_image("einstein.jpg")))
q.choices.where(title:"Seattle's Best").first_or_create!(image:open(seed_image("seattles-best.jpg")))
q.choices.where(title:"Dunkin Donuts").first_or_create!(image:open(seed_image("dunkin.jpg")))

q = ChoiceQuestion.where(title:"How would you split up a $50 million lottery prize?").first_or_create!(rotate:true,category:business,user:user)
q.choices.where(title:"Give it all to charity.").first_or_create!
q.choices.where(title:"80% me, 20% them").first_or_create!
q.choices.where(title:"80% them, 20% me").first_or_create!

q = ChoiceQuestion.where(title:"What made-up language would you like to speak?").first_or_create!(rotate:false,category:sports,user:user)
q.choices.where(title:"Esparanto").first_or_create!
q.choices.where(title:"Igpay Atinlay").first_or_create!
q.choices.where(title:"Klingon").first_or_create!
q.choices.where(title:"Ewok").first_or_create!

q = ChoiceQuestion.where(title:"Which is your favorite season?").first_or_create!(rotate:true,category:values,user:user)
q.choices.where(title:"Summer").first_or_create!(rotate:true)
q.choices.where(title:"Fall").first_or_create!(rotate:true)
q.choices.where(title:"Winter").first_or_create!(rotate:true)
q.choices.where(title:"Spring").first_or_create!(rotate:true)
q.choices.where(title:"...of my discontent").first_or_create!(rotate:false)

q = ChoiceQuestion.where(title:"Which would you give up first?").first_or_create!(rotate:true,category:business,user:user)
q.choices.where(title:"My computer").first_or_create!
q.choices.where(title:"My car").first_or_create!
q.choices.where(title:"My home").first_or_create!
q.choices.where(title:"My vacations").first_or_create!

q = ChoiceQuestion.where(title:"Which of these indulgent drinks is healthier?").first_or_create!(rotate:false,category:values,user:user)
q.choices.where(title:"Starbucks Iced Grande Mocha").first_or_create!
q.choices.where(title:"McDonald's Milkshake").first_or_create!
q.choices.where(title:"Jameson's Mai Tai").first_or_create!

q = ChoiceQuestion.where(title:"How likely is world peace in your lifetime?").first_or_create!(rotate:false,category:sports,user:user)
q.choices.where(title:"No Chance").first_or_create!
q.choices.where(title:"50/50 Chance").first_or_create!
q.choices.where(title:"It's Already Here").first_or_create!

q = ChoiceQuestion.where(title:"How many years do you think you will live?").first_or_create!(rotate:false,category:values,user:user)
q.choices.where(title:"A few more").first_or_create!
q.choices.where(title:"Over 60").first_or_create!
q.choices.where(title:"Over 100").first_or_create!
q.choices.where(title:"Forever").first_or_create!
