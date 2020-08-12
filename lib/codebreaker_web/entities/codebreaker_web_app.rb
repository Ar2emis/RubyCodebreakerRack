# frozen_string_literal: true

module CodebreakerWeb
  class CodebreakerWebApp
    COMMANDS = {
      '' => :menu,
      'statistics' => :statistics,
      'game' => :game,
      'rules' => :rules,
      'lose' => :lose,
      'win' => :win,
      'hint' => :hint,
      'restart' => :restart
    }.freeze

    def self.call(env)
      new(env).response.finish
    end

    def initialize(env)
      @env = env
      @request = Rack::Request.new(@env)
      @game = @request.session[:game]
      @hints = @request.session[:hints].nil? ? [] : @request.session[:hints]
      @answer = @request.session[:answer]
    end

    def response
      command = COMMANDS[@request.path.delete('/')]
      command.nil? ? Rack::Response.new('Page not found', 404) : send(command)
    end

    private

    def menu
      @request.session.clear
      create_response('menu')
    end

    def statistics
      create_response('statistics')
    end

    def game
      return redirect('/') if @game.nil? && game_params_empty?

      @game.nil? ? start_game : continue_game
      if @game.win? then redirect('/win')
      elsif @game.lose? then redirect('/lose')
      else game_response
      end
    end

    def rules
      create_response('rules')
    end

    def win
      return redirect('/') if @game.nil? || @game.lose?
      return redirect('/game') unless @game.win?

      @game.save_statistic
      create_response('win', game: @game)
    end

    def lose
      return redirect('/') if @game.nil? || @game.win?
      return redirect('/game') unless @game.lose?

      create_response('lose', game: @game)
    end

    def hint
      return redirect('/') if @game.nil?
      return redirect('/game') unless @game.hints_amount.positive?

      @request.session[:hints] = @hints << @game.take_hint
      redirect('/game')
    end

    def restart
      return redirect('/') if @game.nil?

      @request.session.clear
      @game.restart
      @request.session[:game] = @game
      redirect('/game')
    end

    def start_game
      user = Codebreaker::User.new(@request.params['player_name'])
      difficulty = Codebreaker::Difficulty.difficulties(@request.params['level'].split.first.downcase.to_sym)
      @game = Codebreaker::Game.new(difficulty, user)
      @game.start
      @request.session[:game] = @game
    end

    def continue_game
      return game_response if @request.params['number'].nil?

      @answer = @game.make_turn(Codebreaker::Guess.new(@request.params['number']))
      @request.session[:answer] = @answer
    end

    def game_response
      create_response('game', game: @game, hints: @hints, answer: @answer)
    end

    def game_params_empty?
      @request.params['player_name'].nil? || @request.params['level'].nil?
    end

    def redirect(page)
      Rack::Response.new { |response| response.redirect(page) }
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
