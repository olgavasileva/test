class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  belongs_to :response
  belongs_to :parent, class_name: 'Comment'
  has_many :children, class_name: 'Comment', foreign_key: :parent_id
  has_many :likes, class_name: 'LikedComment'
  has_many :likers, through: :likes, source: :user

  validates :user, presence: true
  validates :question, presence: true
  validates :body, presence: true
  validate :parent_shares_question

  scope :root, -> { where(parent_id: nil) }

  def parent_shares_question
    if parent.present? && parent.question != question
      errors.add(:parent_id, "must belong to the same question.")
    end
  end
end
