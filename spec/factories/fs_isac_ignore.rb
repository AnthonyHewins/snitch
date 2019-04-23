FactoryBot.define do
  factory :fs_isac_ignore do
    regex_string { FFaker::Lorem.word }
    case_sensitive { [true, false].sample }
  end
end
