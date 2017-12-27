namespace :transactions_polling_manager do
  desc "Start SubscriptionsManagerWorker class"
  task schedule: :environment do
    current_time = DateTime.now
    midnight = DateTime.new(current_time.year, current_time.month, current_time.day, 0,0,0)
    morning = DateTime.new(current_time.year, current_time.month, current_time.day, 6,0,0)
    noon = DateTime.new(current_time.year, current_time.month, current_time.day, 12,0,0)
    afternoon = DateTime.new(current_time.year, current_time.month, current_time.day, 18,0,0)
    latenight = DateTime.new(current_time.year, current_time.month, current_time.day, 24,0,0)
    # start worker at 12am or 6pm or 12pm or 6 am
    [midnight, morning, noon, afternoon, latenight].each do |time|
      if current_time < time
        Ripples::Workers::TransactionsSynchronizationWorker.perform_at(time)
      end
    end
  end
end