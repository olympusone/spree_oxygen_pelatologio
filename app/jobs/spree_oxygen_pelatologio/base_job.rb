module SpreeOxygenPelatologio
  class BaseJob < Spree::BaseJob
    queue_as SpreeOxygenPelatologio.queue
  end
end
