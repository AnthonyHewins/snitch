FactoryBot.define do
  factory :uri_entry do
    dhcp_lease
    hits {rand(1..1000)}
    uri {FFaker::Internet.uri('http')}
  end
end
