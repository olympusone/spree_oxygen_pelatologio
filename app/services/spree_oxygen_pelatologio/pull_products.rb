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

    # Updates Spree variants based on a single Oxygen product payload.
    #
    # Payload expectations (partial):
    # - data['code']              => SKU used to locate a Spree::Variant
    # - data['sale_total_amount'] => incoming price (string/number; coerced to Float)
    # - data['warehouses']        => array of { 'name' => stock location name, 'quantity' => integer-like }
    #
    # Variant selection rules:
    #
    # 1) Locate variant by SKU (data['code'])
    #    - Blank SKU => no-op (cannot map).
    #    - Missing variant => no-op.
    #
    # 2) Decide which variants to update
    #
    #    A) Incoming SKU points to the MASTER variant:
    #       - Update the master variant and any SKU-less variants for the same product.
    #       - Rationale: treat master SKU as a product-level update and propagate to "follower" variants
    #         that cannot be addressed by SKU.
    #
    #    B) Incoming SKU points to a NON-MASTER variant:
    #       - Update only that variant.
    #       - Additionally update the master variant only if the master has a blank SKU.
    #       - Rationale: if the master cannot be addressed by SKU, keep it in sync with sellable variants.
    #
    # 3) What "update" means (see update_variant)
    #    - Price:
    #      - If BOTH `price` and `compare_at_price` are already present => skip price changes entirely
    #        (we do not override variants already configured in a "sale state").
    #      - Otherwise, update `price` if the incoming price is valid (> 0) and different.
    #
    #    - Stock:
    #      - For each warehouse entry, match by stock_location.name.
    #      - If a matching stock_item exists and quantity differs, update via `variant.set_stock`.
    #      - Negative quantities are clamped to 0.
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

      # Preload stock items once and build a lookup keyed by stock location name
      stock_items_by_location_name =
        variant.stock_items.includes(:stock_location).index_by { |si| si.stock_location&.name }

      return if stock_items_by_location_name.empty?

      Array(data['warehouses']).each do |wh|
        location_name = wh['name']
        qty = wh['quantity'].to_i

        stock_item = stock_items_by_location_name[location_name]
        next unless stock_item && !stock_item.count_on_hand.nil? && stock_item.count_on_hand != qty

        # Clamp negative quantities to 0
        count_on_hand = qty.negative? ? 0 : qty

        # Update stock for the specific stock location
        variant.set_stock(count_on_hand, nil, stock_item.stock_location)
      end
    end

    # Updates the variant's price from Oxygen.
    #
    # Rules:
    # - If variant already has BOTH `price` and `compare_at_price`, do nothing.
    #   (We treat that as manually-configured sale pricing and avoid overriding it.)
    # - Ignore invalid incoming prices (<= 0). This also prevents blank payloads turning into 0.0 via to_f.
    # - If price is unchanged, do nothing.
    # - Otherwise, set the price for the variant currency.
    def update_price(variant, new_price)
      return if variant.price.present? && variant.compare_at_price.present?
      return if new_price.nil? || new_price <= 0

      return if variant.price.to_f == new_price

      variant.set_price(variant.currency, new_price)
    end
  end
end
