Rails.application.config.assets.paths << "#{Rails}/vendor/assets/fonts"
Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
Rails.application.config.assets.precompile += %w(clean-canvas.js clean-canvas.css)
Rails.application.config.assets.precompile += %w(pixel_admin.js pixel_admin.css)
