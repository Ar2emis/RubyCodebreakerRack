# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  "https://github.com/#{repo_name}"
end

gem 'codebreaker', github: 'Ar2emis/RubyCodebreaker'
gem 'rack'
gem 'rack_session_access'
gem 'slim'
gem 'tilt'

group :test do
  gem 'capybara'
  gem 'faker'
  gem 'rack-test'
  gem 'rspec'
  gem 'simplecov'
end

group :development do
  gem 'fasterer'
  gem 'lefthook'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'solargraph'
end
