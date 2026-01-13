namespace :spree_oxygen_pelatologio do
  desc "Pull products from Oxygen and sync into Spree"
  task pull_products: :environment do
    SpreeOxygenPelatologio::PullProducts.new.call
  end
end
