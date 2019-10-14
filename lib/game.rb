require_relative "./player"
require_relative "./board"

class Game
    attr_accessor :player1, :player2, :board, :active_player

    def initialize
        @player1 = Player.new('white')
        @player2 = Player.new('black')
        @board = Board.new
        @active_player = @player1
        @inactive_player = @player2
    end

    def round
        board.show
        piece = get_piece
        move = get_move
        move_piece(piece, move)
        switch_players
    end

    private 

    def get_piece
        puts "#{@active_player.color}: Select piece to move"
        input = format(gets.strip)
        until on_board?(input) && correct_color?(input)
            puts "Please select a #{@active_player.color} piece on the board to move"
            input = format(gets.strip)
        end
    end

    def format(input)
        split= input.split("")
        column = split.select { |char| char.match(/[a-h]/)}.flatten
        row = split.select { |num| num.match(/[1-8]/)}.flatten
        until column.length == 1
            puts "Which column did you mean? [a-h]"
            column = gets.strip.split("").select {|char| char.match(/[a-h]/)}.flatten
        end
        until row.length == 1
            puts "Which row did you mean? [1-8]"
            row = gets.strip.split("").select {|num| num.match(/[1-8]/)}.flatten
        end
        output = [row[0].to_i,column[0]]
        output
    end

    def valid_input?(input)

    end
end