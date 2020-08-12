# frozen_string_literal: true

describe CodebreakerWeb::CodebreakerWebApp do
  context 'when gets to /' do
    before { visit '/' }

    it 'returns the status 200' do
      expect(status_code).to be(200)
    end

    it 'displays Codebreaker 2020 on page' do
      expect(page).to have_content 'Codebreaker 2020'
    end

    it 'displays input for entering player name' do
      expect(page).to have_field('player_name')
    end
  end

  context 'when unknown page' do
    before { visit '/wrong' }

    it 'returns the status 404' do
      expect(status_code).to be(404)
    end

    it 'returns page 404' do
      expect(page).to have_content 'Page not found'
    end
  end

  context 'when shows statistics' do
    before do
      visit '/'
      click_link('Statistics')
    end

    it 'returns the status 200' do
      expect(status_code).to be(200)
    end

    it 'returns page with winner results' do
      expect(page).to have_current_path('/statistics')
    end

    it 'displays table with results' do
      expect(page).to have_css('.table-responsive-md.scores')
    end
  end

  context 'with game' do
    let(:name) { Faker::Name.first_name }
    let(:user) { Codebreaker::User.new(name) }
    let(:difficulty) { Codebreaker::Difficulty.difficulties(:easy) }
    let(:game) { Codebreaker::Game.new(difficulty, user) }
    let(:guess_number) { '1234' }

    context 'when game starts' do
      before do
        visit '/'
        fill_in('player_name', with: name)
        select("#{difficulty.name} - #{difficulty.attempts} attempts - #{difficulty.hints} hints", from: 'level')
        click_button('Start the game!')
      end

      it 'returns the status 200' do
        expect(status_code).to be(200)
      end

      it 'returns page with player name' do
        expect(page).to have_content "Hello, #{name}!"
      end

      it 'returns page with message about starting game' do
        expect(page).to have_content 'Try to guess 4-digit number, that consists of numbers in a range from 1 to 6.'
      end

      it 'returns page with N attempts' do
        expect(page).to have_content "Attempts: #{difficulty.attempts}"
      end

      it 'returns page with links' do
        expect(page).to have_link('hint')
      end

      it 'returns page with input for entering guess' do
        expect(page).to have_field('number')
      end
    end

    context 'when makes turn' do
      before do
        game.start
        page.set_rack_session(game: game)
        visit '/game'
        fill_in('number', with: guess_number)
        click_button('Submit')
      end

      it 'returns the status 200' do
        expect(status_code).to be(200)
      end

      it 'displays that N-1 attempts left' do
        expect(page).to have_content "Attempts: #{difficulty.attempts - 1}"
      end
    end

    context 'when press restart game' do
      before do
        game.start
        page.set_rack_session(game: game)
        visit '/game'
        difficulty.attempts.times do
          fill_in('number', with: guess_number)
          click_button('Submit')
        end
        click_link('Play again!')
      end

      it 'returns page with N attempts' do
        expect(page).to have_content "Attempts: #{difficulty.attempts}"
      end
    end

    context 'when press hint' do
      before do
        game.start
        page.set_rack_session(game: game)
        visit '/game'
        click_link('Show hint!')
      end

      it 'show hint' do
        expect(page).to have_content 'Show hint!'
      end
    end
  end
end
