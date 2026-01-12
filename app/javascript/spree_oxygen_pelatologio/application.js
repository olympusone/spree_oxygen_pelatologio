import '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'

let application

if (typeof window.Stimulus === "undefined") {
  application = Application.start()
  application.debug = false
  window.Stimulus = application
} else {
  application = window.Stimulus
}

import SpreeOxygenPelatologioController from 'spree_oxygen_pelatologio/controllers/spree_oxygen_pelatologio_controller' 

application.register('spree_oxygen_pelatologio', SpreeOxygenPelatologioController)