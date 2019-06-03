FactoryBot.define do
  factory :hostname do
    sequence(:name, 1) { |n| "example#{n}.com" }
  end
end
