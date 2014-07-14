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

private_category = Category.where(name:"Private").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
animals = Category.where(name:"Animals").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
art_and_culture = Category.where(name:"Art & Culture").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "business-icon.png"))
motors_and_gears = Category.where(name:"Motors and Gears").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
cleberities = Category.where(name:"Cleberities").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
diy_and_crafts = Category.where(name:"DIY & Crafts").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "business-icon.png"))
movies_and_tv = Category.where(name:"Movies & TV").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
food_and_drink = Category.where(name:"Food & Drink").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
lifestyle = Category.where(name:"Lifestyle").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "business-icon.png"))
geek_and_gaming = Category.where(name:"Geek & Gaming").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
fashion_and_beauty = Category.where(name:"Fashion & Beauty").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
health_and_fitness = Category.where(name:"Health & Fitness").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "business-icon.png"))
news_and_history = Category.where(name:"News & History").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
holiday_and_events = Category.where(name:"Holiday & Events").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
home_and_garden = Category.where(name:"Home & Garden").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "business-icon.png"))
humor = Category.where(name:"Humor").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
family = Category.where(name:"Family").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
sports_and_outdoors = Category.where(name:"Sports & Outdoors").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "sports-icon.png"))
photography = Category.where(name:"Photography").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
consumer = Category.where(name:"Consumer").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
science_and_nature = Category.where(name:"Science & Nature").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "business-icon.png"))
technology = Category.where(name:"Technology").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
places_and_travel = Category.where(name:"Places & Travel").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
weddings = Category.where(name:"Weddings").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "business-icon.png"))
relationships = Category.where(name:"Relationships").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
politics = Category.where(name:"Politics").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
business_and_finance = Category.where(name:"Business & Finance").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "business-icon.png"))
values = Category.where(name:"Values").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
music = Category.where(name:"Music").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))
entertainment = Category.where(name:"Entertainment").first_or_create!(image:open(seed_image "portfolio3.png"), icon:open(seed_image "business-icon.png"))
books = Category.where(name:"Books").first_or_create!(image:open(seed_image "portfolio1.png"), icon:open(seed_image "values-icon.png"))
other = Category.where(name:"Other").first_or_create!(image:open(seed_image "portfolio2.png"), icon:open(seed_image "sports-icon.png"))

#
# Questions
#

q = ChoiceQuestion.where(title:"How much should be spent on meteor-strike prevention?").first_or_create!(rotate:false,category:business_and_finance,user:user)
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

q = ChoiceQuestion.where(title:"How would you split up a $50 million lottery prize?").first_or_create!(rotate:true,category:business_and_finance,user:user)
q.choices.where(title:"Give it all to charity.").first_or_create!
q.choices.where(title:"80% me, 20% them").first_or_create!
q.choices.where(title:"80% them, 20% me").first_or_create!

q = ChoiceQuestion.where(title:"What made-up language would you like to speak?").first_or_create!(rotate:false,category:sports_and_outdoors,user:user)
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

q = ChoiceQuestion.where(title:"Which would you give up first?").first_or_create!(rotate:true,category:business_and_finance,user:user)
q.choices.where(title:"My computer").first_or_create!
q.choices.where(title:"My car").first_or_create!
q.choices.where(title:"My home").first_or_create!
q.choices.where(title:"My vacations").first_or_create!

q = ChoiceQuestion.where(title:"Which of these indulgent drinks is healthier?").first_or_create!(rotate:false,category:values,user:user)
q.choices.where(title:"Starbucks Iced Grande Mocha").first_or_create!
q.choices.where(title:"McDonald's Milkshake").first_or_create!
q.choices.where(title:"Jameson's Mai Tai").first_or_create!

q = ChoiceQuestion.where(title:"How likely is world peace in your lifetime?").first_or_create!(rotate:false,category:sports_and_outdoors,user:user)
q.choices.where(title:"No Chance").first_or_create!
q.choices.where(title:"50/50 Chance").first_or_create!
q.choices.where(title:"It's Already Here").first_or_create!

q = ChoiceQuestion.where(title:"How many years do you think you will live?").first_or_create!(rotate:false,category:values,user:user)
q.choices.where(title:"A few more").first_or_create!
q.choices.where(title:"Over 60").first_or_create!
q.choices.where(title:"Over 100").first_or_create!
q.choices.where(title:"Forever").first_or_create!

q = MultipleChoiceQuestion.where(title:"Choose all of your favorite fruits.").first_or_create(min_responses:1,rotate:false,category:values,user:user)
q.choices.where(title:"Apples").first_or_create!
q.choices.where(title:"Oranges").first_or_create!
q.choices.where(title:"Bananas").first_or_create!
q.choices.where(title:"Pears").first_or_create!

