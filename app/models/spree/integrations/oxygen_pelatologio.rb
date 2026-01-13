module Spree
  module Integrations
    class OxygenPelatologio < Spree::Integration
      preference :api_key, :string
      preference :environment, :string, default: 'production'

      validates :preferred_api_key, presence: true
      validates :preferred_environment, inclusion: { in: %w[production sandbox] }

      def self.integration_group
        'other'
      end

      def self.icon_path
        'integration_icons/oxygen-pelatologio-logo.png'
      end
    end
  end
end
