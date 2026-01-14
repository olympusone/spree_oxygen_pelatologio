module SpreeOxygenPelatologio
  class PullProducts
    attr_reader :client

    def initialize
      @client = SpreeOxygenPelatologio::Client.new
    end

    def call
      client.call(:pull_products) do |products|
        products.each { |product| update_product(product) }
      end
    end

    private

    # Updates Spree variants based on a single product payload coming from Oxygen.
    #
    # Payload expectations (partial):
    # - data['code']                => SKU to identify the Spree::Variant to update
    # - data['sale_total_amount']   => price (numeric-like string/number)
    # - data['warehouses']          => array of { 'name' => stock location name, 'quantity' => integer-like }
    #
    # High-level flow:
    #
    # 1) Identify target variant
    #    - Read SKU from `data['code']`.
    #    - If SKU is blank => do nothing (no way to map to a Spree variant).
    #    - Find `Spree::Variant` by SKU.
    #    - If no variant exists => do nothing.
    #
    # 2) Decide which variants to update (master vs non-master)
    #
    #    A) If the found variant is the MASTER variant:
    #       - Collect all variants for the product (including master).
    #       - Select only:
    #         - the master variant, OR
    #         - variants whose SKU is blank
    #       - Update each selected variant with the same incoming data.
    #
    #       Rationale:
    #       - When the incoming SKU points at the master, we treat it as a "product-level"
    #         update and propagate changes to the master and any SKU-less variants that are
    #         considered to "follow" the master.
    #
    #    B) If the found variant is a NON-MASTER variant:
    #       - Update ONLY that specific variant.
    #       - Additionally, update the product's master variant only if the master has a blank SKU.
    #
    #       Rationale:
    #       - Variant-specific SKUs represent distinct sellable variants.
    #       - A master with blank SKU is treated as a "placeholder" that should stay in sync
    #         with real variants (price/stock), but only when it cannot be independently addressed.
    #
    # 3) What "update" means (delegated to `update_variant`)
    #    - Price: `update_price(variant, data['sale_total_amount'].to_f)`
    #      - If price unchanged => no-op
    #      - If new price is lower => set price and keep compare_at_price
    #      - If new price is higher => set price and clear compare_at_price
    #
    #    - Stock: for each warehouse entry
    #      - Match warehouse name to a Spree stock location name.
    #      - If a matching stock item exists and qty differs => update stock via `variant.set_stock`.
    def update_product(data)
      sku = data['code']
      return if sku.blank?

      variant = Spree::Variant.find_by(sku: sku)
      return unless variant

      if variant.is_master?
        variants = variant.product.variants_including_master.select { |v| v.sku.blank? || v.is_master? }

        variants.each { |v| update_variant(v, data) }
      else
        update_variant(variant, data)

        master_variant = variant.product.master
        update_variant(master_variant, data) if master_variant.sku.blank?
      end
    end

    def update_variant(variant, data)
      update_price(variant, data['sale_total_amount'].to_f)

      # Preload once and build a fast lookup by location name
      stock_items_by_location_name =
        variant.stock_items.includes(:stock_location).index_by { |si| si.stock_location&.name }
      return if stock_items_by_location_name.empty?

      # Update stock
      Array(data['warehouses']).each do |wh|
        location_name = wh['name']
        qty = wh['quantity'].to_i

        stock_item = stock_items_by_location_name[location_name]
        next unless stock_item && !stock_item.count_on_hand.nil? && stock_item.count_on_hand != qty

        # Ensure no negative stock
        count_on_hand = qty.negative? ? 0 : qty
        variant.set_stock(count_on_hand, nil, stock_item.stock_location)
      end
    end

    # Update variant price based on new price
    #
    # If new price is lower, set it as the current price and keep compare_at_price
    # If new price is higher, set it as the current price and clear compare_at_price
    def update_price(variant, new_price)
      return if variant.price.to_f == new_price

      if new_price < variant.price.to_f
        variant.set_price(variant.currency, new_price, variant.compare_at_price)
      elsif new_price > variant.price.to_f
        variant.set_price(variant.currency, new_price)
      end
    end
  end
end
