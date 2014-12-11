class FeedItem < ActiveRecord::Base
  self.table_name = :feed_items_v2

  belongs_to :user
  belongs_to :question

  default hidden: false
  default published_at: lambda { |uq| Time.current }

  scope :hidden, -> {where hidden:true}
  scope :visible, -> {where hidden:false}
  scope :skipped, -> {where hidden:true, hidden_reason:'skipped'}
  scope :answered, -> {where hidden:true, hidden_reason:'answered'}
  scope :suspended, -> {where hidden:true, hidden_reason:'suspended'}
  scope :deleted, -> {where hidden:true, hidden_reason:'deleted'}

  validates :user, presence: true
  validates :question, presence: true
  validates :hidden, inclusion: {in:[true,false]}
  validates :hidden_reason, inclusion: {in:%w(answered skipped suspended deleted), allow_nil: true}
  validates :question_id, uniqueness:{scope: :user_id}

  def self.question_answered! question, user
    question.feed_items.where(user_id: user.id).first.try :question_answered!
  end

  def self.question_skipped! question, user
    question.feed_items.where(user_id: user.id).first.try :question_skipped!
  end

  def self.question_suspended! question
    question.feed_items.visible.update_all hidden:true, hidden_reason:'suspended', hidden_at:Time.current
  end

  def self.question_deleted! question
    question.feed_items.visible.update_all hidden:true, hidden_reason:'deleted', hidden_at:Time.current, question_id:nil
  end


  def skipped?
    hidden && hidden_reason == 'skipped'
  end

  def answered?
    hidden && hidden_reason == 'answered'
  end

  def suspended?
    hidden && hidden_reason == 'suspended'
  end

  def deleted?
    hidden && hidden_reason == 'deleted'
  end


  def question_answered!
    update_attributes hidden: true, hidden_reason: 'answered', hidden_at: Time.current
  end

  def question_skipped!
    update_attributes hidden: true, hidden_reason: 'skipped', hidden_at: Time.current
    question.decrement! :score, 0.25
  end
end
