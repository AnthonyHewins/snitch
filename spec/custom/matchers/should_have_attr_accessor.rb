RSpec::Matchers.define :have_attr_accessor do |field|
  match do |obj|
    obj.respond_to?(field) && obj.respond_to?("#{field}=")
  end

  failure_message do |object_instance|
    "expected attr_accessor for #{field} on #{object_instance}"
  end

  failure_message_when_negated do |object_instance|
    "expected attr_accessor for #{field} not to be defined on #{object_instance}"
  end

  description do
    "have an attr_accessor on @#{field}"
  end
end
