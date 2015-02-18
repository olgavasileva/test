class EmbeddableUnit < ActiveRecord::Base
  belongs_to :survey
  has_many :questions, through: :survey

  default :uuid do |eu|
    "EU"+UUID.new.generate.gsub(/-/, '')
  end

  default width: 300
  default height: 250

  validates :uuid, presence: true
  validates :width, presence: true, numericality: {greater_than: 0}
  validates :height, presence: true, numericality: {greater_than: 0}

  before_save :convert_markdown

  def script request
    <<-END
<script type="text/javascript"><!--
  statisfy_unit = "#{uuid}";
  statisfy_unit_width = #{width}; statisfy_unit_height = #{height};
//-->
</script>
<script type="text/javascript" src="#{request.base_url}/#{Rails.env}/show_unit.js">
</script>
    END
  end

  def iframe request
    "<iframe width=\"#{width}\" height=\"#{height}\" src=\"#{request.base_url}/unit/#{uuid}\" frameborder=\"0\"></iframe>"
  end

  private
    def convert_markdown
      self.thank_you_html = RDiscount.new(thank_you_markdown, :filter_html).to_html unless thank_you_markdown.nil?
    end
end
