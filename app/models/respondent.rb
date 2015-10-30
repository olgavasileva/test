class Respondent < ActiveRecord::Base
  include CustomTrackable

  self.table_name = 'users'

  has_many :responses, dependent: :destroy, foreign_key: :user_id
  has_many :order_responses, class_name: "OrderResponse", foreign_key: :user_id
  has_many :choice_responses, class_name: "ChoiceResponse", foreign_key: :user_id
  has_many :multiple_choice_responses, class_name: "MultipleChoiceResponse", foreign_key: :user_id
  has_many :answered_questions, through: :responses, source: :question, foreign_key: :user_id
  has_many :inappropriate_flags, dependent: :destroy, foreign_key: :user_id
  has_many :scenes, dependent: :destroy, foreign_key: :user_id

  has_many :groups, dependent: :destroy, foreign_key: :user_id
  has_many :group_members, through: :groups, source: :user
  has_many :group_memberships, class_name: 'GroupMember', foreign_key: :user_id
  has_many :membership_groups, through: :group_memberships, source: :group

  has_many :communities, dependent: :destroy, foreign_key: :user_id
  has_many :community_members, through: :communities, source: :member
  has_many :community_memberships, class_name: 'CommunityMember', foreign_key: :user_id
  has_many :membership_communities, through: :community_memberships, source: :community
  has_many :fellow_community_members, through: :membership_communities, source: :member_users

  has_many :targets, dependent: :destroy, foreign_key: :user_id
  has_many :consumer_targets, foreign_key: :user_id
  has_many :enterprise_targets, foreign_key: :user_id

  has_many :targets_users, foreign_key: :user_id
  has_many :following_targets, through: :targets_users, source: :consumer_target

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

  has_many :demographics, dependent: :destroy
  has_one :demographic_summary, dependent: :destroy

  belongs_to :avatar, class_name: "UserAvatar", foreign_key: :user_avatar_id

  # Questions targeted to this respondent
  has_many :question_targets
  has_many :targeted_questions, through: :question_targets, source: :question

  # Things this respondent did with various questions
  has_many :question_actions
  has_many :question_action_skips
  has_many :skipped_questions, through: :question_action_skips, source: :question

  default auto_feed: true

  has_many :surveys, foreign_key: :user_id
  has_many :embeddable_units, through: :surveys
  has_many :embeddable_unit_themes, foreign_key: :user_id
  has_many :listicles, foreign_key: :user_id
  has_many :listicle_responses, foreign_key: :user_id

  VALID_USERNAME_REGEX ||= /\A[a-z0-9\-_]{4,50}\z/i
  validates :username,
              presence: true,
              format: { with: VALID_USERNAME_REGEX },
              length: { maximum: 50 },
              uniqueness: { case_sensitive: false }

  before_validation :ensure_username
  before_create :set_default_role

  # respondents with responses or skips within the last n days
  def self.active n = 10
    joins(:question_actions).where{question_actions.created_at >= Date.current - n.days}.uniq
  end

  # respondents with no responses or skips within the last n days
  def self.inactive n = 10
    a = active(n)
    where{id.not_in(a)}
  end

  # Share count is defined as the number or uniqe original referrers
  def share_count
    responses_to_questions.pluck(:original_referrer).uniq.reject{|c| c.blank?}.count
  end

  def latest_feed
    feed_questions.latest
  end

  def trending_feed
    if Figaro.env.USE_RESPONSE_COUNT_TRENDING?
      feed_questions.trending_on_recent_response_count
    else
      feed_questions.trending
    end
  end

  def my_feed
    feed_questions(omit_public_questions: true, include_public_leader_questions: true).includes(:question_targets).by_relevance
  end

  ##
  # All active public questions plus active questions targeted to this respondent
  # Minus answered and skipped questions
  # Returned as a query
  #
  # Options can be used to modify the result set:
  #    omit_public_questions: don't include public questions (default is false)
  #    include_answered_questions: include answered questions (default is false)
  #    include_skipped_questions: include skipped questions (default is false)
  #    include_public_leader_questions: include active public questions asked by my leaders (default is false)
  def feed_questions options = {}
    options.reverse_merge omit_public_questions: false, include_answered_questions: false, include_skipped_questions: false, include_public_leader_questions: false

    ids = targeted_questions.active.pluck(:id)
    ids += Question.active.publik.pluck(:id) unless options[:omit_public_questions]
    ids += Question.active.publik.where(user: leaders).pluck(:id) if options[:include_public_leader_questions]
    ids -= answered_questions.active.pluck(:id) unless options[:include_answered_questions]
    ids -= skipped_questions.active.pluck(:id) unless options[:include_skipped_questions]

    Question.where id: ids.uniq
  end

  def feed_questions_with_answered
    feed_questions include_answered_questions: true
  end

  def feed_questions_with_skipped
    feed_questions include_skipped_questions: true
  end

  def feed_questions_with_skipped_and_answered
    feed_questions include_skipped_questions: true, include_answered_questions: true
  end

  def choice_ids_made_for_question question
    @choice_ids ||= {}
    @choice_ids[question.id] ||= responses.where(question_id:question).pluck(:choice_id)
  end

  def quantcast_demographic_required?
    demographics.quantcast.blank? || demographics.quantcast.first.updated_at < (Date.current - 1.month)
  end

  # Comments made by other users about this user's questions and responses
  def comments_on_questions_and_responses
    Comment.where id:(comments_on_its_questions.pluck("comments.id") + comments_on_its_responses.pluck("comments.id"))
  end

  def following? leader
    leaders.include? leader
  end

  def follow! leader
    unless leaders.include? leader
      self.leaders << leader
      add_and_push_message leader
    end
  end

  def unfollow! leader
    followership_relationships.where(leader_id:leader.id).destroy_all
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

  def under_13?
    raise NotImplementedError.new("You must implement this method in a subclass")
  end

  def age
    raise NotImplementedError.new("You must implement this method in a subclass")
  end

  def name
    raise NotImplementedError.new("You must implement this method in a subclass")
  end

  def is_pro?
    false
  end

  def valid_surveys(reload = false)
    @valid_surveys = nil if reload
    @valid_surveys ||= surveys.includes(:questions).reject { |survey| survey.questions.empty? }
  end

  def web_app_url_with_auth(path='')
    instance = instances.last
    instance = Instance.create_null_instance(self) if instance.nil?
    unless instance.auth_token.present?
      instance.refresh_auth_token
      instance.save
    end
    "#{ENV['WEB_APP_URL']}/#/#{path}?auth_token=#{instance.auth_token}" +
        "&instance_token=#{instance.uuid}&registered_user=#{username}"
  end

  private
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

    def add_and_push_message(followed_user)

      message = UserFollowed.new

      message.follower = self
      message.user = followed_user
      message.read_at = nil

      if message.save
        followed_user.instances.where.not(push_token:nil).each do |instance|
          instance.push alert:"#{username} followed you",
                        badge:messages.count,
                        sound:true,
                        other: {  type: message.type,
                                  created_at: message.created_at,
                                  read_at: message.read_at,
                                  follower_id: message.follower_id }
        end
      end
    end

    def set_default_role
      self.roles << Role.publisher if type != 'Anonymous'
    end
end
