FactoryBot.define do
  factory :paper_trail do
    filename { FFaker::Lorem.word }
    insertion_date { FFaker::Time.date }
  end
end
