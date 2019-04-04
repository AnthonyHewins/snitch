FactoryBot.define do
  factory :machine do
    paper_trail
    sequence(:host) {|n| FFaker::Lorem.word + n.to_s}
    sequence(:user) {|n| FFaker::Lorem.word + n.to_s}
  end
end
