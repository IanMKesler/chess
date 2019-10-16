require_relative "./player"
require_relative "./board"

class Game
    attr_accessor :player1, :player2, :board, :active_player, :inactive_player

    def initialize
        @player1 = Player.new('white')
        @player2 = Player.new('black')
        @board = Board.new
        set_board
        @active_player = @player1
        @inactive_player = @player2
    end

    def round
        @active_player.check = check?
        checkmate? if @active_player.check
        if @active_player.checkmate || stalemate
            return true
        end
        board.show
        puts "Check!" if @active_player.check
        piece = get_piece
        old_position = piece.position
        new_position = get_move(piece)
        taken_piece = @board.field[new_position[0]][new_position[1]]
        move(piece, old_position, new_position)
        while @active_player.check
            puts "Your king is still in check! Try another move."
            move(piece, new_position, old_position)
            piece = get_piece
            old_position = piece.position
            new_position = get_move(piece)
            @active_player.check = check?
        end
        switch_players
    end

    private 

    def checkmate?
        
    end

    def check?
        king = find_pieces(@active_player, "King")[0]
        pawns = find_pieces(@inactive_player, "Pawn")
        others = @inactive_player.pieces - pawns
        threats = others.select { |piece| valid_move?(piece, king.position)}
        threats += pawns.select { |piece| valid_take?(piece, king.position)}
        threats.length > 0 ? true : false
    end

    def move(piece, old_position, new_position)
        taken_piece = @board.field[new_position[0]][new_position[1]]
        @board.field[new_position[0]][new_position[1]] = piece
        @board.field[old_position[0]][old_position[1]] = nil
        piece.move(new_position)
        if @taken_piece
            case @taken_piece.color
            when 'white'
                @player1.taken << @player1.pieces.delete(taken_piece)
            when 'black'
                @player2.taken << @player2.pieces.delete(taken_piece)
            end
        end
        set_board
    end

    def valid_take?(piece, position)
        return piece.valid_takes.include?(position) ? true : false
    end

    def valid_move?(piece, position)
        type = piece.class.superclass.name
        case type
        when "Slider"
            lane = piece.valid_moves.select { |lane| lane.include?(position)}.flatten(1)
            lane.each_with_index do |position, index|
                if @board.field[position[0]][position[1]]
                    case @board.field[position[0]][position[1]].color
                    when piece.color
                        lane = lane[0...index]
                        break
                    else
                        lane = lane[0..index]
                        break
                    end
                end
            end
            return lane.include?(position) ? true : false
        else 
            return piece.valid_moves.include?(position) ? true : false
        end
    end

    def find_pieces(player, piece_name)
        player.pieces.select { |piece| piece.class.name == piece_name}
    end

    def get_move(piece)
        puts "Move #{@active_player.color} #{piece.class.to_s} to:"
        input = format(gets.strip)
        until valid_move?(input, piece)
            puts "Not a valid move for that piece, try again."
            input = format(gets.strip)
        end
        input
    end

    def set_board
        @player1.pieces.each do |piece|
            row = piece.position[0]
            column = piece.position[1]
            @board.field[row][column] = piece
        end
        @player2.pieces.each do |piece|
            row = piece.position[0]
            column = piece.position[1]
            @board.field[row][column] = piece
        end
        
    end

    def get_piece
        puts "#{@active_player.color}: Select piece"
        input = format(gets.strip)
        until correct_piece?(input)
            puts "Please select a #{@active_player.color} piece on the board."
            input = format(gets.strip)
        end
        @board.field[input[0]][input[1]]
    end

    def correct_piece?(input)
        piece = @board.field[input[0]][input[1]]
        @active_player.pieces.include?(piece)
    end

    def format(input)
        split= input.downcase.split("")
        column = split.select { |char| char.match(/[a-h]/)}.flatten
        row = split.select { |num| num.match(/[1-8]/)}.flatten
        until column.length == 1
            puts "Which column did you mean? [a-h]"
            column = gets.strip.downcase.split("").select {|char| char.match(/[a-h]/)}.flatten
        end
        until row.length == 1
            puts "Which row did you mean? [1-8]"
            row = gets.strip.downcase.split("").select {|num| num.match(/[1-8]/)}.flatten
        end
        output = [7-(row[0].to_i-1),board.column_reference.key(column[0])]
        output
    end
end