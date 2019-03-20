RSpec::Matchers.define :have_abstract_method do |field|
  match do |obj|
    expect{obj.send field}.to raise_error NotImplementedError
    expect(obj.protected_methods).to include field
  end

  failure_message do |object_instance|
    "expected ##{field} to be abstract method (protected and raise NotImplementedError)"
  end

  failure_message_when_negated do |object_instance|
    "expected ##{field} not to be abstract (raise NotImplementedError or not be protected)"
  end

  description do
    "has protected abstract method ##{field}"
  end
end
