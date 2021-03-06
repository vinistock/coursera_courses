FactoryGirl.define do
  factory :image do
    sequence(:caption) { |n| n%2==0 ? nil : Faker::Lorem.sentence(1).chomp('.') }
    creator_id 1
    image_content { attributes_for(:image_content) }

    after(:build) do |image|
      image.image_content = build(:image_content, image.image_content) if image.image_content
    end

    trait :with_caption do
      caption { Faker::Lorem.sentence(1).chomp('.') }
    end
  end
end
