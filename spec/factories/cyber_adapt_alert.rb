FactoryBot.define do
  factory :cyber_adapt_alert do
    sequence(:alert_id)
    alert {FFaker::Lorem.word}
    msg {FFaker::Lorem.word}
    src_ip {FFaker::Internet.ip_v4_address}
    dst_ip {FFaker::Internet.ip_v4_address}
    src_port {rand(6500)}
    dst_port {rand(6500)}
    alert_timestamp {FFaker::Time.datetime}
  end
end
