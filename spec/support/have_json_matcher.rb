# With a controller `response` as the subject, it matches human
# readable codes like `:not_found` or `:no_content`
#
RSpec::Matchers.define :have_json_key do |expected|
  match do |actual|
    @json = actual.is_a?(String) ? JSON.parse(actual) : actual.stringify_keys
    has_key? && has_value?
  end

  chain :eq do |value|
    @value = value
  end

  description do
    "have JSON key #{expected}"
  end

  failure_message do |actual|
    msg  = "expected JSON to have key #{expected}"
    msg += " equal to #{@value}" if @value
    msg += ", but it did not"
  end

  failure_message_when_negated do |actual|
    "expected JSON to not have key #{expected}"
  end

  def has_key?
    @json.keys.include?(expected.to_s)
  end

  def has_value?
    !@value || @json[expected.to_s] == @value
  end
end
