FactoryBot.define do
  factory :whitelist do
    paper_trail
    regex_string { FFaker::Lorem.word + "[0-9]*" }
  end
end
