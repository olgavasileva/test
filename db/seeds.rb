# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#
# API Settings (served in instance call)
#
Setting.where(key: :google_gtm).first_or_create!(value: nil)
Setting.where(key: :faq_url).first_or_create!(value: "http://www.crashmob.com/?page_id=668")
Setting.where(key: :feedback_url).first_or_create!(value: "http://www.crashmob.com/?page_id=674")
Setting.where(key: :about_url).first_or_create!(value: "http://www.crashmob.com/?page_id=670")
Setting.where(key: :terms_and_conditions_url).first_or_create!(value: "http://www.crashmob.com/?page_id=672")
Setting.where(key: :aws_access_key).first_or_create!(value: ENV['DEVICE_AWS_ACCESS_KEY'])
Setting.where(key: :aws_secret_access_key).first_or_create!(value: ENV['DEVICE_AWS_SECRET_ACCESS_KEY'])
Setting.where(key: :aws_region).first_or_create!(value: ENV['DEVICE_AWS_REGION'])
Setting.where(key: :aws_bucket).first_or_create!(value: ENV['DEVICE_AWS_BUCKET'])

%w(Calories Fat Carbohydrates Protein).each do |key|
  Key.where(key:key).first_or_create!
end

#
# Users
#

Role.where(name:"pro").first_or_create!
user = User.where(username:'crashmob').first_or_create!(name:"Question Master",email:'question-master@crashmob.com',password:"dirty socks",password_confirmation:"dirty socks")
user.add_role :pro


def background_image filename
  File.join "db","seeds","backgrounds",filename
end

question_image_files = %w(bluegrunge.png bluetriangle.png bluetriangular.png bluewall.png greengrunge.png greentriangle.png greentriangular.png greenwall.png redgrunge.png redtriangle.png redtriangular.png redwall.png yellowgrunge.png yellowtriangle.png yellowtriangular.png yellowwall.png)
existing_file_paths = CannedQuestionImage.all.map{|f|f.image.path}
question_image_files.each_with_index do |image_file, position|
  CannedQuestionImage.create image:open(background_image image_file) unless existing_file_paths.find {|fp| fp.match /#{image_file}$/}
end

choice_image_files = %w(bluegrunge.png bluetriangle.png bluetriangular.png bluewall.png greengrunge.png greentriangle.png greentriangular.png greenwall.png redgrunge.png redtriangle.png redtriangular.png redwall.png yellowgrunge.png yellowtriangle.png yellowtriangular.png yellowwall.png)
existing_file_paths = CannedChoiceImage.all.map{|f|f.image.path}
choice_image_files.each_with_index do |image_file, position|
  CannedChoiceImage.create image:open(background_image image_file) unless existing_file_paths.find {|fp| fp.match /#{image_file}$/}
end

order_choice_image_files = %w(bluegrunge.png bluetriangle.png bluetriangular.png bluewall.png greengrunge.png greentriangle.png greentriangular.png greenwall.png redgrunge.png redtriangle.png redtriangular.png redwall.png yellowgrunge.png yellowtriangle.png yellowtriangular.png yellowwall.png)
existing_file_paths = CannedOrderChoiceImage.all.map{|f|f.image.path}
order_choice_image_files.each_with_index do |image_file, position|
  CannedOrderChoiceImage.create image:open(background_image image_file) unless existing_file_paths.find {|fp| fp.match /#{image_file}$/}
end


#
# Access to background image assets
#

def random_question_image_id
  CannedQuestionImage.all.pluck(:id).sample
end

def random_choice_image_id
  CannedChoiceImage.all.pluck(:id).sample
end

def random_order_image_id
  CannedOrderChoiceImage.all.pluck(:id).sample
end

#
# Categories
#
def seed_image filename
  File.join "db","seeds",filename
end

private_category = Category.where(name:"Private").first_or_create!(icon:open(seed_image "categories/PrivateConvo150.png"))
animals = Category.where(name:"Animals").first_or_create!(icon:open(seed_image "categories/Animals150.png"))
art_and_culture = Category.where(name:"Art & Culture").first_or_create!(icon:open(seed_image "categories/ArtAndCulture150.png"))
motors_and_gears = Category.where(name:"Motors and Gears").first_or_create!(icon:open(seed_image "categories/MotorsAndGears150.png"))
cleberities = Category.where(name:"Cleberities").first_or_create!(icon:open(seed_image "categories/Celebs150.png"))
diy_and_crafts = Category.where(name:"DIY & Crafts").first_or_create!(icon:open(seed_image "categories/DIYAndCrafts150.png"))
movies_and_tv = Category.where(name:"Movies & TV").first_or_create!(icon:open(seed_image "categories/MoviesAndTV150.png"))
food_and_drink = Category.where(name:"Food & Drink").first_or_create!(icon:open(seed_image "categories/FoodAndDrink150.png"))
lifestyle = Category.where(name:"Lifestyle").first_or_create!(icon:open(seed_image "categories/LifeStyle150.png"))
geek_and_gaming = Category.where(name:"Geek & Gaming").first_or_create!(icon:open(seed_image "categories/GeekAndGaming150.png"))
fashion_and_beauty = Category.where(name:"Fashion & Beauty").first_or_create!(icon:open(seed_image "categories/FashionAndBeauty150.png"))
health_and_fitness = Category.where(name:"Health & Fitness").first_or_create!(icon:open(seed_image "categories/HealthAndFitness150.png"))
news_and_history = Category.where(name:"News & History").first_or_create!(icon:open(seed_image "categories/NewsAndHistory150.png"))
holiday_and_events = Category.where(name:"Holiday & Events").first_or_create!(icon:open(seed_image "categories/HolidayAndEvents150.png"))
home_and_garden = Category.where(name:"Home & Garden").first_or_create!(icon:open(seed_image "categories/HomeAndGarden150.png"))
humor = Category.where(name:"Humor").first_or_create!(icon:open(seed_image "categories/Humor150.png"))
family = Category.where(name:"Family").first_or_create!(icon:open(seed_image "categories/Family150.png"))
sports_and_outdoors = Category.where(name:"Sports & Outdoors").first_or_create!(icon:open(seed_image "categories/SportsAndOutdoors150.png"))
photography = Category.where(name:"Photography").first_or_create!(icon:open(seed_image "categories/Photography150.png"))
consumer = Category.where(name:"Consumer").first_or_create!(icon:open(seed_image "categories/Consumer150.png"))
science_and_nature = Category.where(name:"Science & Nature").first_or_create!(icon:open(seed_image "categories/ScienceAndNature150.png"))
technology = Category.where(name:"Technology").first_or_create!(icon:open(seed_image "categories/Technology150.png"))
places_and_travel = Category.where(name:"Places & Travel").first_or_create!(icon:open(seed_image "categories/PlacesAndTravel150.png"))
weddings = Category.where(name:"Weddings").first_or_create!(icon:open(seed_image "categories/Weddings150.png"))
relationships = Category.where(name:"Relationships").first_or_create!(icon:open(seed_image "categories/Relationship150.png"))
politics = Category.where(name:"Politics").first_or_create!(icon:open(seed_image "categories/Politics150.png"))
business_and_finance = Category.where(name:"Business & Finance").first_or_create!(icon:open(seed_image "categories/BusinessAndFinance150.png"))
values = Category.where(name:"Values").first_or_create!(icon:open(seed_image "categories/Values150.png"))
music = Category.where(name:"Music").first_or_create!(icon:open(seed_image "categories/Music150.png"))
entertainment = Category.where(name:"Entertainment").first_or_create!(icon:open(seed_image "categories/Entertainment150.png"))
books = Category.where(name:"Books").first_or_create!(icon:open(seed_image "categories/Books150.png"))
other = Category.where(name:"Other").first_or_create!(icon:open(seed_image "categories/Other150.png"))

#
# Questions
#

q = TextChoiceQuestion.where(title:"Do you like green eggs and ham?").first_or_create!(state:"active",rotate:false,category:fashion_and_beauty,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Yes").first_or_create!
q.choices.where(title:"No").first_or_create!

q = TextChoiceQuestion.where(title:"How much should be spent on meteor-strike prevention?").first_or_create!(state:"active",rotate:false,category:home_and_garden,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"About $1").first_or_create!
q.choices.where(title:"Up to $100").first_or_create!
q.choices.where(title:"Up to $1,000").first_or_create!
q.choices.where(title:"Over $1,000").first_or_create!

q = ImageChoiceQuestion.where(title:"Who’s coffee do you prefer?").first_or_create!(state:"active",rotate:true,category:food_and_drink,user:user)
q.choices.where(title:"Starbucks").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("starbucks.jpg"))))
q.choices.where(title:"Einstein's").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("einstein.jpg"))))
q.choices.where(title:"Seattle's Best").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("seattles-best.jpg"))))
q.choices.where(title:"Dunkin Donuts").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("dunkin.jpg"))))

q = TextChoiceQuestion.where(title:"How would you split up a $50 million lottery prize?").first_or_create!(state:"active",rotate:true,category:consumer,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Give it all to charity.").first_or_create!
q.choices.where(title:"80% me, 20% them").first_or_create!
q.choices.where(title:"80% them, 20% me").first_or_create!

q = TextChoiceQuestion.where(title:"What made-up language would you like to speak?").first_or_create!(state:"active",rotate:false,category:places_and_travel,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Esparanto").first_or_create!
q.choices.where(title:"Igpay Atinlay").first_or_create!
q.choices.where(title:"Klingon").first_or_create!
q.choices.where(title:"Ewok").first_or_create!

q = TextChoiceQuestion.where(title:"Which is your favorite season?").first_or_create!(state:"active",rotate:true,category:science_and_nature,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Summer").first_or_create!(rotate:true)
q.choices.where(title:"Fall").first_or_create!(rotate:true)
q.choices.where(title:"Winter").first_or_create!(rotate:true)
q.choices.where(title:"Spring").first_or_create!(rotate:true)

q = TextChoiceQuestion.where(title:"Which would you give up first?").first_or_create!(state:"active",rotate:true,category:lifestyle,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"My computer").first_or_create!
q.choices.where(title:"My car").first_or_create!
q.choices.where(title:"My home").first_or_create!
q.choices.where(title:"My vacations").first_or_create!

q = TextChoiceQuestion.where(title:"Which of these indulgent drinks is healthier?").first_or_create!(state:"active",rotate:false,category:food_and_drink,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Starbucks Iced Grande Mocha").first_or_create!
q.choices.where(title:"McDonald's Milkshake").first_or_create!
q.choices.where(title:"Jameson's Mai Tai").first_or_create!

q = TextChoiceQuestion.where(title:"How likely is world peace in your lifetime?").first_or_create!(state:"active",rotate:false,category:news_and_history,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"No Chance").first_or_create!
q.choices.where(title:"50/50 Chance").first_or_create!
q.choices.where(title:"It's Already Here").first_or_create!

q = TextChoiceQuestion.where(title:"How many years do you think you will live?").first_or_create!(state:"active",rotate:false,category:lifestyle,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"A few more").first_or_create!
q.choices.where(title:"Over 60").first_or_create!
q.choices.where(title:"Over 100").first_or_create!
q.choices.where(title:"Forever").first_or_create!

q = MultipleChoiceQuestion.where(title:"Choose all of your favorite coffee houses.").first_or_create!(state:"active",min_responses:1,rotate:false,category:food_and_drink,user:user)
q.choices.where(title:"Starbucks").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("starbucks.jpg"))))
q.choices.where(title:"Einstein's").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("einstein.jpg"))))
q.choices.where(title:"Seattle's Best").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("seattles-best.jpg"))))
q.choices.where(title:"Dunkin Donuts").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("dunkin.jpg"))))

q = MultipleChoiceQuestion.where(title:"Choose all of the utencils you use.").first_or_create!(state:"active",min_responses:1,rotate:false,category:food_and_drink,user:user)
q.choices.where(title:"Fork").first_or_create!(background_image_id:random_choice_image_id)
q.choices.where(title:"Knife").first_or_create!(background_image_id:random_choice_image_id)
q.choices.where(title:"Spoon").first_or_create!(background_image_id:random_choice_image_id)
q.choices.where(title:"Spork").first_or_create!(background_image_id:random_choice_image_id)

q = OrderQuestion.where(title:"Rate these in order of best to worst.").first_or_create!(state:"active",rotate:true,category:food_and_drink,user:user)
q.choices.where(title:"Starbucks").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("starbucks.jpg"))))
q.choices.where(title:"Einstein's").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("einstein.jpg"))))
q.choices.where(title:"Seattle's Best").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("seattles-best.jpg"))))
q.choices.where(title:"Dunkin Donuts").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("dunkin.jpg"))))

q = OrderQuestion.where(title:"Rate these in order of fastest to slowest.").first_or_create!(state:"active",rotate:true,category:humor,user:user)
q.choices.where(title:"The Blue Angels").first_or_create!(background_image_id:random_order_image_id)
q.choices.where(title:"Forest Gump").first_or_create!(background_image_id:random_order_image_id)
q.choices.where(title:"Madonna").first_or_create!(background_image_id:random_order_image_id)

q = TextQuestion.where(title:"What do you like about travelling?").first_or_create!(state:"active",category:places_and_travel,user:user, text_type:"freeform", min_characters:1, max_characters:200, background_image_id:random_question_image_id)
