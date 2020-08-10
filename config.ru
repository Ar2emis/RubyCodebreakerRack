# frozen_string_literal: true

require_relative 'lib/codebreaker_web'
require 'delegate'

use Rack::Reloader
use Rack::Static, urls: %w[/bootstrap /jquery], root: 'node_modules'
use Rack::Static, urls: ['/assets'], root: 'views'
use Rack::Session::Cookie, key: 'rack.session',
                           secret: 'secretKey'

run CodebreakerWeb::CodebreakerWebApp
