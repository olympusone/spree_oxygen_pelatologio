FactoryBot.define do
  factory :oxygen_pelatologio_integration, class: Spree::Integrations::EltaCourier do
    active { true }
    preferred_api_key { ENV['OXYGEN_PELATOLOGIO_API_KEY'] }
    store { Spree::Store.default }
  end
end
