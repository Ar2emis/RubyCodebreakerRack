# frozen_string_literal: true

module CodebreakerWeb
  class CodebreakerWebApp
    include WebHelper

    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @env = env
      @request = Rack::Request.new(env)
    end

    def response
      command = @request.path.delete('/')
      case command
      when '' then menu
      when 'statistics' then statistics
      when 'rules' then rules
      else
        %(game win lose hint restart).include?(command) ? GameWeb.call(@env) : response_404
      end
    end

    private

    def menu
      @request.session.clear
      create_response('menu')
    end

    def statistics
      create_response('statistics')
    end

    def rules
      create_response('rules')
    end
  end
end
