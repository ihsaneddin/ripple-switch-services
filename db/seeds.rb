# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#Users::Models::Plan.destroy_all

unless Users::Models::Plan.exists?
  #
  # seed subscriptions plan
  #
  Users::Models::Plan.transaction do 
    [
      {
        name: "Starter",
        price: 0,
        currency: "USD",
        position: 1,
        free: true,
        features: {
          max_wallets_count: 10,
          max_api_request_per_second: 1
        },
        description: "<p>10 Wallet Addresses per Network</p>
                      <p>1 API Request per Second</p>"
      },
      {
        name: "Intermediate",
        price: 50,
        currency: "USD",
        position: 2,
        features: {
          max_wallets_count: 100,
          max_api_request_per_second: 5
        },
        description: "<p>100 Wallet Addresses per Network</p>
                      <p>5 API Request per Second</p>"
      },
      {
        name: "Advance",
        price: 150,
        currency: "USD",
        position: 3,
        features: {
          max_wallets_count: 1000,
          max_api_request_per_second: 25
        },
        description: "<p>1000 Wallet Addresses per Network</p>
                      <p>25 API Request per Second</p>"
      },
      {
        name: "Expert",
        price: 500,
        currency: "USD",
        position: 4,
        features: {
          max_wallets_count: 5000,
          max_api_request_per_second: 100
        },
        description: "<p>5000 Wallet Addresses per Network</p>
                      <p>100 API Request per Second</p>"
      },
      {
        name: "Exchanger",
        price: 0,
        currency: "USD",
        position: 5,
        features: {
          max_wallets_count: 0,
          max_api_request_per_second: 0
        },
        description: "<p>Unlimited Wallet Addresses per Network</p>
                      <p>Unlimited API Request per Second</p>"
      }
    ].each do |plan_params|
      if Users::Models::Plan.create plan_params
        puts "Plan #{plan_params[:name]} created successfully"
      else
        puts "Plan #{plan_params[:name]} failed to be created"
        puts "Rolling back.."
        raise ActiveRecord::Rollback
      end
    end
  end
end

#
# seed development records
#

unless Rails.env.production?

  unless Users::Models::Account.exists?
    account = Users::Models::Account.new email: 'rss-user@mailinator.com', password: 'password', password_confirmation: 'password'
    account.skip_confirmation!
    puts "seed account created.\n"if account.save
  end

  unless Administration::Models::Admin.exists?
    admin = Administration::Models::Admin.new email: "rss-admin@mailinator.com", password: "password", password_confirmation: "password"
    admin.skip_confirmation!
    puts "admin user created\n" if admin.save
  end

else

end