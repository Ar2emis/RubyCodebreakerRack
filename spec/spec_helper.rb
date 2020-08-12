# frozen_string_literal: true

require 'faker'
require 'rack'
require 'rack/test'
require 'capybara/rspec'
require 'rack_session_access/capybara'

require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter 'spec/'
  minimum_coverage 90
end

require 'codebreaker_web'

content = File.read(File.expand_path('../config.ru', __dir__))
Capybara.app = Rack::Builder.new { eval content }

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Capybara::DSL

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
