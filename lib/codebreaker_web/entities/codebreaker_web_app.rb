# frozen_string_literal: true

module CodebreakerWeb
  class CodebreakerWebApp
    def self.call(env)
      new(env).response.finish
    end

    def initialize(env); end

    def response
      page = render('menu.slim')
      Rack::Response.new(page)
    end

    private

    def render(filename)
      layout = Tilt.new(full_path('layout.slim'))
      page = Tilt.new(full_path(filename))
      layout.render { page.render }
    end

    def full_path(filename)
      File.join('views', filename)
    end
  end
end
