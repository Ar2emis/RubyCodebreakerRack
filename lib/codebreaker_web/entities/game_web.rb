# frozen_string_literal: true

module CodebreakerWeb
  class GameWeb
    include WebHelper

    def self.call(env)
      new(env).response
    end

    def initialize(env)
      @request = Rack::Request.new(env)
      @game = @request.session[:game]
      @hints = @request.session[:hints].nil? ? [] : @request.session[:hints]
      @guess = @request.session[:guess]
      @answer = @request.session[:answer]
    end

    def response
      command = @request.path.delete('/')
      case command
      when 'game' then game
      when 'hint' then hint
      when 'win' then win
      when 'lose' then lose
      when 'restart' then restart
      else redirect('/')
      end
    end

    def game
      return redirect('/') if @game.nil? && game_params_empty?

      @game.nil? ? start_game : continue_game
      if @game.win? then redirect('/win')
      elsif @game.lose? then redirect('/lose')
      else game_response
      end
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

      @guess = @request.params['number']
      @request.session[:guess] = @guess
      @answer = @game.make_turn(Codebreaker::Guess.new(@guess))
      @request.session[:answer] = @answer
    end

    def game_response
      create_response('game', game: @game, hints: @hints, answer: @answer, guess: @guess)
    end

    def game_params_empty?
      @request.params['player_name'].nil? || @request.params['level'].nil?
    end
  end
end
