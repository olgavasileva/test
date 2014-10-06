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
Setting.where(key: :share_app).first_or_create!(value: "Check out this app!")
Setting.where(key: :share_question).first_or_create!(value: "Check out this question!")
Setting.where(key: :share_community_public).first_or_create!(value: "Check this out!")
Setting.where(key: :share_community_private).first_or_create!(value: "Check this out!")

#
# Push notification setup
#

push_app_name = 'Statisfy'
Rpush::Apns::App.where(name:push_app_name,environment:"development").first_or_create(connections:1, certificate:File.read("#{Rails.root}/certs/crashmob_dev_push.pem"))
Rpush::Apns::App.where(name:push_app_name,environment:"production").first_or_create(connections:1, certificate:File.read("#{Rails.root}/certs/crashmob_production_push.pem"))
Instance.where(push_app_name:nil).each{|i|i.update_attribute :push_app_name, push_app_name}


#
# Keys for studio
#

%w(Calories Fat Carbohydrates Protein Sugar SaturatedFat Sodium Cholesterol Fiber CaloriesFromFat).each do |key|
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

# Revised to match v20140905
satisfied = Category.where(name:"Are you statisfied?").first_or_create!(icon:open(seed_image "AreYouStatisfied150.png"))
celebs = Category.where(name:"Celebrities & Pop").first_or_create!(icon:open(seed_image "CelebritiesAndPop150.png"))
dating = Category.where(name:"Dating & Relationships").first_or_create!(icon:open(seed_image "DatingAndRelationship150.png"))
entertainment = Category.where(name:"Entertainment").first_or_create!(icon:open(seed_image "Entertainment150.png"))
fashion = Category.where(name:"Fashion").first_or_create!(icon:open(seed_image "Fashion150.png"))
feminism = Category.where(name:"Feminisms for the World").first_or_create!(icon:open(seed_image "FeminismsForTheWorld150.png"))
food_and_drink = Category.where(name:"Food & Drink").first_or_create!(icon:open(seed_image "FoodAndDrink150.png"))
geek = Category.where(name:"Geek & Gaming").first_or_create!(icon:open(seed_image "GeekAndGaming150.png"))
health = Category.where(name:"Health & Fitness").first_or_create!(icon:open(seed_image "HealthAndFitness150.png"))
hacks = Category.where(name:"Life Hacks").first_or_create!(icon:open(seed_image "LifeHacks150.png"))
life = Category.where(name:"Life").first_or_create!(icon:open(seed_image "Life150.png"))
lol = Category.where(name:"LOL").first_or_create!(icon:open(seed_image "LOL150.png"))
news = Category.where(name:"News").first_or_create!(icon:open(seed_image "News150.png"))
omg = Category.where(name:"OMG").first_or_create!(icon:open(seed_image "OMG150.png"))
politics = Category.where(name:"Politics").first_or_create!(icon:open(seed_image "Politics150.png"))
shit = Category.where(name:"Shit you should know").first_or_create!(icon:open(seed_image "StuffYouShouldKnow.png"))
sports = Category.where(name:"Sports").first_or_create!(icon:open(seed_image "Sports150.png"))
tech = Category.where(name:"Tech").first_or_create!(icon:open(seed_image "Technology150.png"))
awkward = Category.where(name:"That’s awkward").first_or_create!(icon:open(seed_image "ThatsAkward150.png"))
busy = Category.where(name:"The art of looking busy").first_or_create!(icon:open(seed_image "TheArtOfLookingBusy.png"))
travel = Category.where(name:"Travel").first_or_create!(icon:open(seed_image "Travel150.png"))
rather = Category.where(name:"Would You Rather").first_or_create!(icon:open(seed_image "WouldYouRather150.png"))
wtf = Category.where(name:"WTF").first_or_create!(icon:open(seed_image "WTF150.png"))
science = Category.where(name:"Science").first_or_create!(icon:open(seed_image "Science150.png"))
nsfw = Category.where(name:"Not Safe For Work (NSFW)").first_or_create!(icon:open(seed_image "NSFW150.png"))

#
# Questions
#

q = TextChoiceQuestion.where(title:"Do you like green eggs and ham?").first_or_create!(state:"active",rotate:false,category:health,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Yes").first_or_create!
q.choices.where(title:"No").first_or_create!

q = TextChoiceQuestion.where(title:"How much should be spent on meteor-strike prevention?").first_or_create!(state:"active",rotate:false,category:politics,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"About $1").first_or_create!
q.choices.where(title:"Up to $100").first_or_create!
q.choices.where(title:"Up to $1,000").first_or_create!
q.choices.where(title:"Over $1,000").first_or_create!

q = ImageChoiceQuestion.where(title:"Who’s coffee do you prefer?").first_or_create!(state:"active",rotate:true,category:food_and_drink,user:user)
q.choices.where(title:"Starbucks").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("starbucks.jpg"))))
q.choices.where(title:"Einstein's").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("einstein.jpg"))))
q.choices.where(title:"Seattle's Best").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("seattles-best.jpg"))))
q.choices.where(title:"Dunkin Donuts").first_or_create!(background_image:ChoiceImage.create!(image:open(seed_image("dunkin.jpg"))))

q = TextChoiceQuestion.where(title:"How would you split up a $50 million lottery prize?").first_or_create!(state:"active",rotate:true,category:awkward,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Give it all to charity.").first_or_create!
q.choices.where(title:"80% me, 20% them").first_or_create!
q.choices.where(title:"80% them, 20% me").first_or_create!

q = TextChoiceQuestion.where(title:"What made-up language would you like to speak?").first_or_create!(state:"active",rotate:false,category:travel,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Esparanto").first_or_create!
q.choices.where(title:"Igpay Atinlay").first_or_create!
q.choices.where(title:"Klingon").first_or_create!
q.choices.where(title:"Ewok").first_or_create!

q = TextChoiceQuestion.where(title:"Which is your favorite season?").first_or_create!(state:"active",rotate:true,category:science,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Summer").first_or_create!(rotate:true)
q.choices.where(title:"Fall").first_or_create!(rotate:true)
q.choices.where(title:"Winter").first_or_create!(rotate:true)
q.choices.where(title:"Spring").first_or_create!(rotate:true)

q = TextChoiceQuestion.where(title:"Which would you give up first?").first_or_create!(state:"active",rotate:true,category:life,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"My computer").first_or_create!
q.choices.where(title:"My car").first_or_create!
q.choices.where(title:"My home").first_or_create!
q.choices.where(title:"My vacations").first_or_create!

q = TextChoiceQuestion.where(title:"Which of these indulgent drinks is healthier?").first_or_create!(state:"active",rotate:false,category:food_and_drink,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"Starbucks Iced Grande Mocha").first_or_create!
q.choices.where(title:"McDonald's Milkshake").first_or_create!
q.choices.where(title:"Jameson's Mai Tai").first_or_create!

q = TextChoiceQuestion.where(title:"How likely is world peace in your lifetime?").first_or_create!(state:"active",rotate:false,category:news,user:user,background_image_id:random_question_image_id)
q.choices.where(title:"No Chance").first_or_create!
q.choices.where(title:"50/50 Chance").first_or_create!
q.choices.where(title:"It's Already Here").first_or_create!

q = TextChoiceQuestion.where(title:"How many years do you think you will live?").first_or_create!(state:"active",rotate:false,category:life,user:user,background_image_id:random_question_image_id)
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

q = OrderQuestion.where(title:"Rate these in order of fastest to slowest.").first_or_create!(state:"active",rotate:true,category:entertainment,user:user)
q.choices.where(title:"The Blue Angels").first_or_create!(background_image_id:random_order_image_id)
q.choices.where(title:"Forest Gump").first_or_create!(background_image_id:random_order_image_id)
q.choices.where(title:"Madonna").first_or_create!(background_image_id:random_order_image_id)

q = TextQuestion.where(title:"What do you like about travelling?").first_or_create!(state:"active",category:travel,user:user, text_type:"freeform", min_characters:1, max_characters:200, background_image_id:random_question_image_id)
