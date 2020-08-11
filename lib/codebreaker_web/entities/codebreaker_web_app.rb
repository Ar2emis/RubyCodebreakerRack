# frozen_string_literal: true

module CodebreakerWeb
  class CodebreakerWebApp
    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @env = env
    end

    def response
      @request = Rack::Request.new(@env)
      path = @request.path.delete('/')
      case path
      when '' then menu
      when 'statistics' then statistics
      when 'game' then game
      when 'rules' then rules
      else Rack::Response.new('Page not found', 404)
      end
    end

    private

    def menu
      create_response('menu')
    end

    def statistics
      create_response('statistics')
    end

    def game
      create_response('game')
    end

    def rules
      create_response('rules')
    end

    def create_response(page, status = 200, **args)
      Rack::Response.new(render(page, **args), status)
    end

    def render(filename, **args)
      layout = Tilt.new(full_path('layout'))
      page = Tilt.new(full_path(filename))
      layout.render { page.render(Object.new, **args) }
    end

    def full_path(filename)
      "#{File.join('views', filename)}.html.slim"
    end
  end
end
