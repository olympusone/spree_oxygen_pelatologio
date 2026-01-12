Rails.application.config.after_initialize do
  Spree.integrations << Spree::Integrations::OxygenPelatologio

  # Admin partials
  Spree.admin.partials.head << 'spree_oxygen_pelatologio/head'
end
