FactoryBot.define do
  factory :group_event do
    name { Faker::Name.name }
    description { Faker::Lorem.paragraph }
    location { Faker::Address.street_address }
    start_on { Faker::Date.forward(days: 1) }
    end_on { Faker::Date.forward(days: 10) + 1 }
    status { 'draft' }
    user_id { 1 }
  end
end
