class Survey < ActiveRecord::Base

  PERMITTED_REDIRECTS = %w{none internal external}.freeze

  attr_accessor :username

  belongs_to :user, class_name: 'Respondent'

  has_many :questions_surveys, -> { order "questions_surveys.position ASC" }, dependent: :destroy
  has_many :questions, -> { order "questions_surveys.position ASC" }, through: :questions_surveys
  has_many :contests
  has_many :embeddable_units, dependent: :destroy

  accepts_nested_attributes_for :questions_surveys, allow_destroy: true

  before_validation :set_user_from_username_if_present
  before_validation :set_default_redirect
  before_validation :generate_uuid, on: :create

  validates :uuid, presence: true, uniqueness: {case_sensitive: true}
  validate :user_exists?
  validates_inclusion_of :redirect, in: PERMITTED_REDIRECTS
  validates_numericality_of :redirect_timeout,
    only_integer: true,
    allow_nil: true

  delegate :username, to: :user, allow_nil: true

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

  def base_url
    @base_url ||= Setting.fetch_value('ad_unit_cdn', request.base_url)
  end

  def script request, ad_unit
    <<-END
<script type="text/javascript"><!--
  statisfy_unit = "#{uuid}/#{ad_unit.name}";
  statisfy_unit_width = #{ad_unit.width}; statisfy_unit_height = #{ad_unit.height};
//-->
</script>
<script type="text/javascript" src="#{base_url}/#{Rails.env}/show_qp.js">
</script>
    END
  end

  def iframe request, ad_unit
    "<iframe width=\"#{ad_unit.width}\" height=\"#{ad_unit.height}\" src=\"#{base_url}/qp/#{uuid}/#{ad_unit.name}\" frameborder=\"0\"></iframe>"
  end

  private

  def set_user_from_username_if_present
    self.user = Respondent.find_by username:@username if @username.present?
  end

  def set_default_redirect
    self.redirect = PERMITTED_REDIRECTS.first unless redirect.present?
  end

  def user_exists?
    errors.add(:user, :must_exist) unless user.present?
  end

  def convert_markdown
    unless thank_you_markdown.nil? || thank_you_html_changed?
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
