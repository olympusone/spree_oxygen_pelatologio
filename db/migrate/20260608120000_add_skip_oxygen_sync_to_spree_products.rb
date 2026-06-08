class AddSkipOxygenSyncToSpreeProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :spree_products, :skip_oxygen_sync, :boolean, default: false, null: false
  end
end
