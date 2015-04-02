class StatisfyTagParser < ActsAsTaggableOn::DefaultParser
  def self.parse_tag(tag)
    tag.gsub(/[^0-9a-z\_]/i, '')
  end

  def parse
    result = super.map { |t| self.class.parse_tag(t) }.reject(&:empty?)
    ActsAsTaggableOn::TagList.new(*result)
  end
end
