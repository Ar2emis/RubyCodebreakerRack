# frozen_string_literal: true

require 'bundler'
Bundler.setup

require 'rack'
require 'tilt'
require 'slim'

require 'codebreaker'

require_relative 'entities/codebreaker_web_app'
