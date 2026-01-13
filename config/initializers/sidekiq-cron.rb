Sidekiq.configure_server do |config|
  config.on(:startup) do
    puts "[SpreeOxygenPelatologio] Setting up Sidekiq-Cron jobs..."

    Spree::Store.find_each do |store|
      integration = store.store_integration('oxygen_pelatologio')

      job_name = "Oxygen Pelatologio Sync - Hourly"

      if integration
        Sidekiq::Cron::Job.create(
          name: job_name,
          namespace: "SpreeOxygenPelatologio",
          cron: "0 * * * *",
          class: "SpreeOxygenPelatologio::PullProductsWorker",
          queue: SpreeOxygenPelatologio.queue,
          retry: 2
        )

        Sidekiq.logger.info("[SpreeOxygenPelatologio] Cron job ensured: #{job_name}")
      else
        existing = Sidekiq::Cron::Job.find(job_name)
        existing&.destroy
        Sidekiq.logger.info("[SpreeOxygenPelatologio] Cron job removed (integration disabled): #{job_name}")
      end
    end
  end
end