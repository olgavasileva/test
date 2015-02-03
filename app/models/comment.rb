class Comment < ActiveRecord::Base
  include Rakismet::Model

  rakismet_attrs  :author => proc { user.username },
                  :author_email => proc { user.email },
                  :user_ip => :user_ip,
                  :content => :body

  attr_accessor :user_ip

  belongs_to :user, class_name: "Respondent"
  belongs_to :commentable, :polymorphic => true

  has_many :likes, class_name: 'LikedComment', dependent: :destroy
  has_many :likers, through: :likes, source: :user
  has_many :comments, as: :commentable, dependent: :destroy

  validates :user, presence: true
  validates :body, presence: true

  def question
    case commentable_type
    when "Question"
      commentable
    when "Response"
      commentable.try(:question)
    when "Comment"
      commentable.try(:question)
    end
  end
end
