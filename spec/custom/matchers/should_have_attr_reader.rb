RSpec::Matchers.define :have_attr_reader do |field|
  match do |obj|
    obj.respond_to?(field)
  end

  failure_message do |object_instance|
    "expected attr_reader for #{field} on #{object_instance}"
  end

  failure_message_when_negated do |object_instance|
    "expected attr_reader for #{field} not to be defined on #{object_instance}"
  end

  description do |object_instance|
    "have an attr_reader on @#{field}"
  end
end
