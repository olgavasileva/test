class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true

  has_many :likes, class_name: 'LikedComment'
  has_many :likers, through: :likes, source: :user
  has_many :comments, as: :commentable

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
