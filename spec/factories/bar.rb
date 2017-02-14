FactoryGirl.define do
  factory :bar do
    name { Faker::Team.name.titleize }
  end
end
