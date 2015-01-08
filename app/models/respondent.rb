class Respondent < ActiveRecord::Base
  self.table_name = 'users'

  has_many :responses, dependent: :destroy, foreign_key: :user_id
  has_many :order_responses, class_name: "OrderResponse", foreign_key: :user_id
  has_many :choice_responses, class_name: "ChoiceResponse", foreign_key: :user_id
  has_many :multiple_choice_responses, class_name: "MultipleChoiceResponse", foreign_key: :user_id
  has_many :feed_items, dependent: :destroy, foreign_key: :user_id
  has_many :feed_questions, -> { where(feed_items_v2:{hidden: false}).where("feed_items_v2.published_at <= ?", Time.current).active }, through: :feed_items, source: :question, foreign_key: :user_id
  has_many :answered_questions, through: :responses, source: :question, foreign_key: :user_id
  has_many :inappropriate_flags, dependent: :destroy, foreign_key: :user_id
  has_many :scenes, dependent: :destroy, foreign_key: :user_id

  has_many :groups, dependent: :destroy, foreign_key: :user_id
  has_many :group_members, through: :groups, source: :user
  has_many :group_memberships, class_name: 'GroupMember', foreign_key: :user_id
  has_many :membership_groups, through: :group_memberships, source: :group

  has_many :communities, dependent: :destroy, foreign_key: :user_id
  has_many :community_members, through: :communities, source: :user
  has_many :community_memberships, class_name: 'CommunityMember', foreign_key: :user_id
  has_many :membership_communities, through: :community_memberships, source: :community

  has_many :targets, dependent: :destroy, foreign_key: :user_id
  has_many :enterprise_targets, dependent: :destroy, foreign_key: :user_id

  has_many :targets_users, foreign_key: :user_id
  has_many :following_targets, through: :targets_users, source: :target

  has_many :messages, dependent: :destroy, foreign_key: :user_id

  has_many :followership_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :leaders, through: :followership_relationships, source: :leader

  has_many :leadership_relationships, class_name: "Relationship", foreign_key: "leader_id", dependent: :destroy
  has_many :followers, through: :leadership_relationships, source: :follower

  has_many :instances, dependent: :destroy, foreign_key: :user_id

  has_many :devices, through: :instances

  # Questions asked by this user
  has_many :questions, dependent: :destroy, foreign_key: :user_id

  # Responses to this user's questions
  has_many :responses_to_questions, through: :questions, source: :responses

  has_many :packs, dependent: :destroy, foreign_key: :user_id
  has_many :sharings, foreign_key: "sender_id", dependent: :destroy
  has_many :reverse_sharings, foreign_key: "receiver_id", class_name: "Sharing", dependent: :destroy

  # Comments made by this user
  has_many :comments, dependent: :destroy, foreign_key: :user_id
  has_many :question_comments, -> {where commentable_type:"Question"}, class_name: "Comment", foreign_key: :user_id
  has_many :response_comments, -> {where commentable_type:"Response"}, class_name: "Comment", foreign_key: :user_id
  has_many :comment_comments, -> {where commentable_type:"Comment"}, class_name: "Comment", foreign_key: :user_id

  # Comments made by other users about this user's responses or questions
  has_many :comments_on_its_responses, through: :responses_to_questions, source: :comment
  has_many :comments_on_its_questions, through: :questions, source: :comments

  has_many :segments, dependent: :destroy, foreign_key: :user_id

  VALID_USERNAME_REGEX ||= /\A[a-z0-9\-_]{4,50}\z/i
  validates :username,
              presence: true,
              format: { with: VALID_USERNAME_REGEX },
              length: { maximum: 50 },
              uniqueness: { case_sensitive: false }

  before_validation :ensure_username

  default :auth_token do |user|
    Respondent.generate_auth_token
  end

  def regenerate_auth_token
    self.auth_token = Respondent.generate_auth_token
  end

  # Comments made by other users about this user's questions and responses
  def comments_on_questions_and_responses
    Comment.where id:(comments_on_its_questions.pluck("comments.id") + comments_on_its_responses.pluck("comments.id"))
  end

  def following? leader
    self.followership_relationships.where(leader_id: leader.id).present?
  end

  def follow! leader

    count = self.leaders.count
    self.leaders << leader

    if self.leaders.count != count
      add_and_push_message leader
    end

  end

  def unfollow! leader
    self.leaders.where(id:leader.id).destroy!
  end

  def read_all_messages
    messages.find_each { |m| m.update_attributes(read_at: Time.zone.now) }
  end

  def number_of_answered_questions
    return Response.where(user_id:id).count
  end

  def number_of_asked_questions
    return Question.where(user_id:id).count
  end

  def number_of_comments_left
    return self.comments.count
  end

  def number_of_followers
    return self.followers.count
  end

  def number_of_unread_messages
    return self.messages.where("read_at is ?", nil).count
  end

  # Clear and then add all the active public questions to the feed
  def reset_feed!
    transaction do
      feed_items.destroy_all
      items = []
      Question.active.publik.order("created_at ASC").each do |q|
        items << FeedItem.new(user:self, question:q, published_at:q.created_at, why: "public")
      end
      FeedItem.import items
    end
  end

  def under_13?
    raise NotImplementedError.new("You must implement this method in a subclass")
  end

  def age
    raise NotImplementedError.new("You must implement this method in a subclass")
  end

  def name
    raise NotImplementedError.new("You must implement this method in a subclass")
  end

  private
    def self.generate_auth_token
       "A"+UUID.new.generate
    end

    def ensure_username
      if username.nil?
        self.username = random_username
        while Respondent.find_by(username:self.username).present?
          self.username = random_username
        end
      end
    end

    COLORS = %w(Antique Aqua Azure Beige Bisque Black Blue Brown Burly CadetBlue Chartreuse Chocolate Coral Cornflower Cornsilk Crimson Cyan Forest Fuchsia Gold Gray Green Honey Indigo Ivory Khaki Lavender Lemon Lime LimeGreen Linen Magenta Maroon Midnight Mint Misty Moccasin Navy OldLace Olive Orange Orchid Papaya Peach Peru Pink Plum Powder Purple Red Rosy Royal Saddle Salmon Sandy Sea Sienna Silver SkyBlue Slate Snow Spring Steel Tan Teal Thistle Tomato Turquoise Violet Wheat White Smoke Yellow)
    ANIMALS = %w(Aardvark Albatross Alligator Alpaca Ant Anteater Antelope Ape Armadillo Baboon Badger Barracuda Bat Bear Beaver Bee Bison Boar Buffalo Butterfly Camel Capybara Caribou Cassowary Cat Caterpillar Chamois Cheetah Chicken Chimpanzee Chinchilla Chough Clam Cobra Cockroach Cod Cormorant Coyote Crab Crane Crocodile Crow Curlew Deer Dinosaur Dog Dogfish Dolphin Donkey Dotterel Dove Dragonfly Duck Dugong Dunlin Eagle Echidna Eel Eland Elephant Elk Emu Falcon Ferret Finch Fish Flamingo Fly Fox Frog Gaur Gazelle Gerbil GiantPanda Giraffe Gnat Gnu Goat Goose Goldfinch Goldfish Gorilla Goshawk Grasshopper Grouse Guanaco GuineaFowl GuineaPig Gull Hamster Hare Hawk Hedgehog Heron Herring Hippopotamus Hornet Horse Human Hummingbird Hyena Ibex Ibis Jackal Jaguar Jay Jellyfish Kangaroo Kingfisher Koala KomodoDragon Kookabura Kouprey Kudu Lapwing Lark Lemur Leopard Lion Llama Lobster Locust Loris Louse Lyrebird Magpie Mallard Manatee Mandrill Mantis Marten Meerkat Mink Mole Mongoose Monkey Moose Mouse Mosquito Mule Narwhal Newt Nightingale Octopus Okapi Opossum Oryx Ostrich Otter Owl Oyster Panther Parrot Partridge Peafowl Pelican Penguin Pheasant Pig Pigeon PolarBear Pony Porcupine Porpoise Quail Quelea Quetzal Rabbit Raccoon Rail Ram Rat Raven RedDeer RedPanda Reindeer Rhinoceros Rook Salamander Salmon SandDollar Sandpiper Sardine Scorpion SeaLion SeaUrchin Seahorse Seal Shark Sheep Shrew Skunk Snail Snake Sparrow Spider Spoonbill Squid Squirrel Starling Stingray Stinkbug Stork Swallow Swan Tapir Tarsier Termite Tiger Toad Trout Turkey Turtle Viper Vulture Wallaby Walrus Wasp Weasel Whale Wildcat Wolf Wolverine Wombat Worm Wren Yak Zebra)

    def random_username
      COLORS.sample + ANIMALS.sample + random_number(rand(2..5))
    end

    def random_number digits
      Random.new.rand(10**(digits-1)..10**digits-1).to_s
    end
end