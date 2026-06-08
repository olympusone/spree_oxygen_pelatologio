Rails.application.config.after_initialize do
  Spree.integrations << Spree::Integrations::OxygenPelatologio

  # Admin partials
  Spree.admin.partials.head << 'spree_oxygen_pelatologio/head'
  Spree.admin.partials.product_form_sidebar << 'spree/admin/products/oxygen_pelatologio_sync'

  # Permit skip_oxygen_sync through strong parameters on product forms
  Spree::PermittedAttributes.product_attributes << :skip_oxygen_sync
end
