RSpec::Matchers.define :have_css do |expected, times|
  match do |actual|
    selector = HTML::Selector.new(expected).select(actual)
    if times
      expect(selector).to have(times).matchs
    else
      expect(selector).to have_at_least(1).match
    end
  end

  failure_message_for_should do |actual|
    "expected #{actual.to_s} to have #{times || 1} elements matching '#{expected}'"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual.to_s} not to have #{times || 1} elements matching '#{expected}'"
  end
end
