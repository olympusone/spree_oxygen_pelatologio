require "sidekiq/cron/web" # require the cron extension

Spree::Core::Engine.add_routes do
  # Add your extension routes here
end
