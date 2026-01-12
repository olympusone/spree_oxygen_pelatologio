pin 'application-spree-oxygen-pelatologio', to: 'spree_oxygen_pelatologio/application.js', preload: false

pin_all_from SpreeOxygenPelatologio::Engine.root.join('app/javascript/spree_oxygen_pelatologio/controllers'),
             under: 'spree_oxygen_pelatologio/controllers',
             to:    'spree_oxygen_pelatologio/controllers',
             preload: 'application-spree-oxygen-pelatologio'
