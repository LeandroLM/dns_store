FactoryBot.define do
  factory :dns_record do
    sequence(:ip_address, 1) { |n| "#{n}.#{n}.#{n}.#{n}" }
  end
end
