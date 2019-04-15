FactoryBot.define do
  factory :fs_isac_alert do
    title         { FFaker::Lorem.sentence }

    tracking_id { rand(10000) }

    alert             { FFaker::Lorem.paragraph }
    affected_products { FFaker::Lorem.paragraph }
    corrective_action { FFaker::Lorem.paragraph }
    sources           { FFaker::Lorem.paragraph }

    alert_timestamp { FFaker::Time.datetime }
    created_at      { FFaker::Time.datetime }
    updated_at      { FFaker::Time.datetime }
  end
end
