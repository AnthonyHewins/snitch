FactoryBot.define do
  factory :whitelist do
    regex_string { FFaker::Lorem.word + "[0-9]*" }
  end
end
