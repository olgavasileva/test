class Comment < ActiveRecord::Base
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
