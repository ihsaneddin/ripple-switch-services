# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#
# seed development records
#

unless Rails.env.production?

  account = Users::Models::Account.new email: 'rss-user@mailinator.com', password: 'password', password_confirmation: 'password'
  account.skip_confirmation!
  account.save

end