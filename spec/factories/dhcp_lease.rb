FactoryBot.define do
  factory :dhcp_lease do
    paper_trail
    machine
    ip {FFaker::Internet.ip_v4_address}
  end
end
