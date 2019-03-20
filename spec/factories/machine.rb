FactoryBot.define do
  factory :machine do
    ip {FFaker::Internet.ip_v4_address}
    sequence(:host) {|n| FFaker::Lorem.word + n.to_s}
    sequence(:user) {|n| FFaker::Lorem.word + n.to_s}
  end
end
