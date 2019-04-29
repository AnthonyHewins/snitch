FactoryBot.define do
  factory :user do
    name { FFaker::Lorem.word }
    admin { [true, false].sample }
    password { FFaker::BaconIpsum.characters(10) }
  end
end
