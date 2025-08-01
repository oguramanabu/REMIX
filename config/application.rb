require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Remix
  class Application < Rails::Application
    config.generators do |g|
      g.assets false
      g.javascripts false
      g.stylesheets false
      g.helper false
      g.fixture false
      g.view_specs false
      g.request_specs false
      g.routing_specs false
      g.controller_specs false
      g.skip_routes true
      g.test_framework :rspec
    end

    config.i18n.default_locale = :ja

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.hosts << "remix-xlro.onrender.com"
  end
end
