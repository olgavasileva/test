class Survey < ActiveRecord::Base

  belongs_to :user, class_name: 'Respondent'

  has_many :questions_surveys, -> { order "questions_surveys.position ASC" }, dependent: :destroy
  has_many :questions, -> { order "questions_surveys.position ASC" }, through: :questions_surveys
  has_many :contests
  has_many :embeddable_units, dependent: :destroy

  accepts_nested_attributes_for :questions_surveys, allow_destroy: true

  before_validation :generate_uuid, on: :create
  validates :uuid, presence: true, uniqueness: {case_sensitive: true}
  validate :user_exists?

  before_save :convert_markdown

  def next_question question
    q = questions_surveys.where(question_id:question).first
    q.lower_items.first.try(:question) unless q.nil?
  end

  private

  def user_exists?
    errors.add(:user, :must_exist) unless user.present?
  end

  def convert_markdown
    unless thank_you_markdown.nil?
      html = RDiscount.new(thank_you_markdown, :filter_html).to_html
      self.thank_you_html = html
    end
  end

  def generate_uuid
    begin
      self.uuid = "S" + UUID.new.generate.gsub(/-/, '')
    end while self.class.exists?(uuid: self.uuid)
  end
end
