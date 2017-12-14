namespace :subscriptions_manager_worker do
  desc "Start SubscriptionsManagerWorker class"
  task start: :environment do
    Ripples::Workers::SubscriptionsManagerWorker.perform_async
  end
end