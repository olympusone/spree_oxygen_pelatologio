module SpreeOxygenPelatologio
  class PullProductsWorker
    include Sidekiq::Worker

    def perform
      Rails.logger.info "[SpreeOxygenPelatologio] Starting PullProductsWorker..."
      SpreeOxygenPelatologio::PullProducts.new.call
      Rails.logger.info "[SpreeOxygenPelatologio] Finished PullProductsWorker."
    end
  end
end
