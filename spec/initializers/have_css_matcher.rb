RSpec::Matchers.define :have_css do |expected, times|
  match do |actual|
    HTML::Selector.new(expected).select(actual).should have_at_least(times || 1).entry
  end

  failure_message_for_should do |actual|
    "expected #{actual.to_s} to have #{times || 1} elements matching '#{expected}'"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual.to_s} not to have #{times || 1} elements matching '#{expected}'"
  end
end
