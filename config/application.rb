require File.expand_path('../boot', __FILE__)

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module Api
  class Application < Rails::Application
    Mongoid.load!('./config/mongoid.yml')
    config.generators { |g| g.orm :active_record }
    config.active_record.raise_in_transactional_callbacks = true

    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins /https:\/\/stock-\w+\.herokuapp\.com/

        resource '*',
                 headers: :any,
                 expose: %w(access-token expiry token-type uid client),
                 methods: [:get, :post, :put, :delete, :options]
      end
    end
  end
end
