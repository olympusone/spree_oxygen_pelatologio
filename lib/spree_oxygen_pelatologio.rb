require 'spree_core'
require 'spree_extension'
require 'spree_oxygen_pelatologio/engine'
require 'spree_oxygen_pelatologio/version'
require 'spree_oxygen_pelatologio/configuration'

module SpreeOxygenPelatologio
  mattr_accessor :queue

  def self.queue
    @@queue ||= Spree.queues.default
  end
end
