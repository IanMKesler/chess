require_relative "./game"
require 'yaml'

def play_game(game)
    players = [game.player1, game.player2]
    game.board.show
    state = game.round
    while state == true
        game.board.show
        state = game.round
    end
    if state.is_a?(String)
        save_game(game) if state.match(/\A[Ss]\z/)
        return false
    end
    checkmate = false
    players.each do |player|
        if player.check
            checkmate = true
            puts "#{player.color} has been checkmated!"
        end
    end
    puts "Stalemate!" unless checkmate
    return true
end

def save_game(game)
    yaml = YAML::dump(game)
    game_file = File.open("save.txt", "w") 
    game_file.puts yaml
    game_file.close
    puts "Game saved!"
end

def load_game
    yaml = File.read("save.txt")
    File.delete("save.txt")
    YAML::load(yaml)
end

def get_continue
    puts "Would you like to play again? (y/n)"
    response =  gets.strip
    valid = response.match(/\A[YNyn]\z/) ? true : false
    until valid
        puts "Please input either 'y' for continue, or 'n' for quit."
        response = gets.strip
        valid = response.match(/\A[YNyn]\z/) ? true : false
    end
    response
end

def yes?(response)
    yes = response.match(/[Yy]/)
    if yes
        return true
    else
        return false
    end
end

def get_load
    puts "Saved game detected. Would you like to load this game? (y/n)"
    response = gets.strip
    valid = response.match(/\A[YNyn]\z/) ? true : false
    until valid
        puts "Please input either 'y' to load the game, or 'n' to start a new game."
        response = gets.strip
        valid = response.match(/\A[YNyn]\z/) ? true : false
    end
    response
end

def create_game
    if File.exist?('save.txt')
        game = load_game if yes?(get_load)
    else
        game = Game.new
        set_computer(game)
    end
    game
end

def set_computer(game)
    puts "Would you like to play against the (c)omputer or a (h)uman?"
    response = gets.strip
    until response.match(/\A[CcHh]\z/)
        puts "Please input 'c' to play against the computer, or 'h' to play against another human."
        response = gets.strip
    end
    if response.match(/\A[Cc]\z/)
        set_player_color(game)   
    end
end

def set_player_color(game)
    puts "Would you like to play as (w)hite or (b)lack?"
    response = gets.strip
    until response.match(/\A[WwBb]\z/)
        puts "Input 'w' for white or 'b' for black."
        response = gets.strip
    end
    if response.match(/\A[Ww]\z/)
        puts "You're now white."
        game.player2.computer = true
    else
        puts "You're now black."
        game.player1.computer = true
    end
end

puts "Welcome to Chess!"
game = create_game

ended = play_game(game)
while ended
    if yes?(get_continue)
        game = create_game
        ended = play_game(game)
    else
        break
    end
end
puts "Thanks for playing!"





