# frozen_string_literal: true

require 'bundler'
Bundler.setup

require 'rack'
require 'tilt'
require 'slim'

require 'codebreaker'

require_relative 'modules/web_helper'

require_relative 'entities/game_web'
require_relative 'entities/codebreaker_web_app'
