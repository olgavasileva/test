class Contest < ActiveRecord::Base
  belongs_to :survey
  belongs_to :key_question, class_name:"Question"
  has_many :contest_response_votes, dependent: :destroy
  has_many :questions, through: :survey
  has_many :questions_surveys, through: :survey

  default :uuid do |contest|
    "C"+UUID.new.generate.gsub(/-/, '')
  end

  before_save :convert_heading

  def next_question question
    questions_surveys.where(question_id:question).first.lower_items.first.try(:question)
  end

  private
    def convert_heading
      self.heading_html = RDiscount.new(heading_markdown, :filter_html).to_html unless heading_markdown.nil?
    end


end
