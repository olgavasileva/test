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

  # Assuming `question_surveys: [:question]` was used to eager load the Survey,
  # this is INFINITELY faster than a database query
  def next_question(question)
    items = questions_surveys.to_a
    index = 0
    found = false

    begin
      found = (items[index].try(:question_id) == question.id)
      index += 1
    end while !found && index < items.length

    found && (index < items.length) && items[index].question
  end

  # Assuming `question_surveys: [:question]` was used to eager load the Survey,
  # this is INFINITELY faster than a database query
  #
  def previous_question(question)
    items = questions_surveys.to_a
    index = items.length - 1
    found = false

    begin
      item = items[index]
      found = (items[index].try(:question_id) == question.id)
      index -= 1
    end while !found && index >= 0

    found && (index >= 0) && items[index].question
  end

  # Replace %key% or %key|default% strings with values from the hash
  # For example, the string: "This is a %xyz%."
  # with a hash of {"xyz" => "test"} results in "This is a test."
  # And "This is a %pdq|cat%." with the same hash results in "This is a cat."
  # Multiple replacements can be included.
  def parsed_thank_you_html hash
    if thank_you_html.present?
      thank_you_html.gsub(/%[^%]+%/) do |s|
        s.match /%([^\|]*)(\|([^%]*))?%/ do |matches|
          hash[matches[1]] || matches[3]
        end
      end
    else
      "Thank you!"
    end
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
