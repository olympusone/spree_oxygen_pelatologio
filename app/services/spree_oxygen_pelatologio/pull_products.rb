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

    def update_product(data)
      sku = data['code']
      return if sku.blank?

      variant = Spree::Variant.find_by(sku: sku)
      return unless variant

      # Update price
      update_price(variant, data['sale_total_amount'].to_f)

      # Preload once and build a fast lookup by location name
      stock_items_by_location_name =
        variant.stock_items.includes(:stock_location).index_by { |si| si.stock_location&.name }

      # Update stock
      data['warehouses'].each do |wh|
        location_name = wh['name']
        qty = wh['quantity'].to_i

        stock_item = stock_items_by_location_name[location_name]
        next unless stock_item && stock_item.count_on_hand != qty

        variant.set_stock(qty, nil, stock_item.stock_location)
      end
    end

    # Update variant price based on new price
    #
    # If new price is lower, set it as the current price and keep compare_at_price
    # If new price is higher, set it as the current price and clear compare_at_price
    def update_price(variant, new_price)
      return if variant.price == new_price

      if new_price < variant.price
        variant.set_price(variant.currency, new_price, variant.compare_at_price)
      elsif new_price > variant.price
        variant.set_price(variant.currency, new_price)
      end
    end
  end
end
