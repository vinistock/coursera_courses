require 'mongoid-rspec'
require 'factory_girl_rails'
require 'capybara'
require 'capybara/poltergeist'

require_relative 'support/api_helper'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Mongoid::Matchers, orm: :mongoid
  config.include FactoryGirl::Syntax::Methods
  config.include ApiHelper, type: :request

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  config.before(:each) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner.start
  end

  config.before(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

Capybara.configure do |config|
  config.default_driver = :rack_test
  config.javascript_driver = :poltergeist
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_logger: StringIO.new)
end

if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec'
    add_filter '/config'
    add_group 'cities', ['city']
    add_group 'states', ['state']
  end
end
