FactoryGirl.define do
  factory :foo, parent: :foo_faker do
  end

  factory :foo_sequence, class: 'Foo' do
    sequence(:name) { |n| "test-#{n}" }
  end

  factory :foo_transient, class: 'Foo' do
    transient do
      male true
    end

    after(:build) do |object, props|
      object.name = props.male ? 'Mr Test' : 'Mrs Test'
    end
  end

  factory :foo_ctor, class: 'Foo' do
    transient do
      hash {}
    end

    initialize_with { Foo.new(hash) }
  end

  factory :foo_faker, class: 'Foo' do
    name { Faker::Name.name }
  end
end
