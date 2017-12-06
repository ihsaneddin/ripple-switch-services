# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )


# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")
Rails.application.config.assets.paths << Rails.root.join("vendor", "assets", "fonts")
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)$/
Rails.application.config.assets.paths << Rails.root.join("vendor", "assets", "images")
Rails.application.config.assets.precompile += %w[*.png *.jpg *.jpeg *.gif] 

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# add stylesheets assets
Rails.application.config.assets.precompile += %w( sessions.css account.css )

# add scripts assets
Rails.application.config.assets.precompile += %w( sessions.js account.js custom.js wallet.js )