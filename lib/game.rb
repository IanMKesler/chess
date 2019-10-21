require_relative "./player"
require_relative "./board"
require 'yaml'

class Game
    attr_accessor :player1, :player2, :board, :active_player, :inactive_player

    def initialize
        @player1 = Player.new('white')
        @player2 = Player.new('black')
        @board = Board.new
        set_board
        @active_player = @player1
        @inactive_player = @player2
        @state = []
    end

    def round
        opponent_moves = construct_legal_moves(@inactive_player)
        @active_player.check = check?(opponent_moves)
        legal_moves = construct_legal_moves(@active_player)
        if no_moves?(legal_moves)
            return false
        end
        piece = get_piece
        move = get_move(piece)
        until legal_moves[piece].include?(move)
            puts "That's an invalid move! Try again."
            piece = get_piece
            move = get_move(piece)
        end
        move(piece, move)
        @active_player, @inactive_player = @inactive_player, @active_player
        return true
    end

    private 

    def no_moves?(legal_moves)
        legal_moves.each do |piece,moves|
            return false unless moves.empty?
        end
        return true
    end

    def construct_legal_moves(player)
        legal_moves = {}
        player.pieces.each do |piece|
            legal_moves[piece] = piece.valid_moves
        end

        legal_moves = add_castles(legal_moves) if player == @active_player && player.check == false
        legal_moves = remove_blocks(legal_moves)
        legal_moves = add_pawn_takes(legal_moves)
        legal_moves = add_en_passant(legal_moves)
        legal_moves = remove_check_moves(legal_moves) if player == @active_player
        legal_moves
    end

    def add_en_passant(legal_moves)
        pawns = legal_moves.select { |piece, moves|
            piece.class.name == "Pawn"
        }
        pawns.each do |pawn, moves|
            pawn.valid_takes.each do |take|
                case pawn.color
                when 'white'
                    opponent = @board.field[take[0]+1][take[1]]
                    if opponent.class.name == 'Pawn' && opponent.color != pawn.color && opponent.en_passant
                        legal_moves[pawn] << take
                    end
                when 'black'
                    opponent = @board.field[take[0]-1][take[1]]
                    if opponent.class.name == 'Pawn' && opponent.color != pawn.color && opponent.en_passant
                        legal_moves[pawn] << take
                    end
                end
            end
        end
        legal_moves
    end


    def castle_move(king, rook)
        row= king.position[0]
        case king.position[1] > rook.position[1]
        when true #Queen-side
            return [row, 2]
        when false #King-side
            return [row, 6]
        end
    end

    def castle?(king, rook)
        row = king.position[0]
        case king.position[1] > rook.position[1]
        when true #Queen-side
            between = (rook.position[1]+1...king.position[1]).to_a
            between.each do |column|
                return false if @board.field[row][column]
            end
            king_moves = between[-2..-1]
            king_moves.each do |column|
                move(king, [row,column])
                opponent_moves = construct_legal_moves(@inactive_player)
                threatened = check?(opponent_moves)
                unmove(king)
                return false if threatened
            end
            return true
        when false #King-side
            between = (king.position[1]+1...rook.position[1]).to_a
            between.each do |column|
                return false if @board.field[row][column]
            end
            king_moves = between[0..1]
            king_moves.each do |column|
                move(king, [row,column])
                opponent_moves = construct_legal_moves(@inactive_player)
                valid = check?(opponent_moves)
                unmove(king)
                return false if valid
            end
            return true
        end
    end

    def add_castles(legal_moves)
        castles = []
        king = @active_player.find_pieces("King")
        rooks = @active_player.find_pieces("Rook")
        if king.moved || rooks.select{ |rook| rook.moved == false}.length == 0
            return legal_moves
        end
        rooks.each do |rook|
            castles << castle_move(king, rook) if castle?(king, rook)
        end 
        legal_moves[king] += castles
        legal_moves
    end


    def remove_check_moves(legal_moves)
        legal_moves.each do |piece, moves|
            moves.select! { |space|
                move(piece,space)
                opponent_moves = construct_legal_moves(@inactive_player)
                valid = check?(opponent_moves) ? false : true
                unmove(piece)
                valid
            }
            legal_moves[piece] = moves
        end
        legal_moves
    end

    def add_pawn_takes(legal_moves)
        pawns = legal_moves.select { |piece, moves|
            piece.class.name == "Pawn"
        }
        pawns.each do |pawn, moves|
            pawn.valid_takes.each do |take|
                opponent = @board.field[take[0]][take[1]]
                if opponent && opponent.color != pawn.color
                    legal_moves[pawn] << take
                end
            end
        end
        legal_moves
    end

    def remove_blocks(legal_moves)
        legal_moves.each { |piece, moves|
            type = piece.class.superclass.name
            case type
            when "Slider"
                moves.map! do |lane|
                    modified_lane(piece.color, lane)
                end
                legal_moves[piece] = moves.flatten(1)
            when "Piece"
                moves.select! { |space|
                    valid = @board.field[space[0]][space[1]] ? false : true
                    valid
                }
                legal_moves[piece] = moves
            else 
                moves.select! { |space|
                    valid = true
                    occupant = @board.field[space[0]][space[1]]
                    if occupant && occupant.color == piece.color
                        valid = false
                    end
                    valid
                }
                legal_moves[piece] = moves
            end
        }
    end

    def modified_lane(color,lane)
        lane.each_with_index do |position, index|
            if @board.field[position[0]][position[1]]
                case @board.field[position[0]][position[1]].color
                when color
                    lane = lane[0...index]
                    break
                else
                    lane = lane[0..index]
                    break
                end
            end
        end
        lane
    end

    def check?(opponent_moves)
        king = @active_player.find_pieces("King")
        opponent_moves.each do |piece, moves|
            if moves.include?(king.position)
                return true
            end
        end
        return false
    end

    def unmove(post_move_piece)
        state = @state.select { |state| 
            state[2] == post_move_piece
        }[-1]
        return false if state.empty?
        pre_move_piece = state[0]
        taken_piece = state[1]

        if taken_piece
            case taken_piece.color
            when 'white'
                @player1.taken[-1].moved = taken_piece.moved
                @player1.pieces << @player1.taken.pop
            when 'black'
                @player2.taken[-1].moved = taken_piece.moved
                @player2.pieces << @player2.taken.pop
            end
        end

        post_position = post_move_piece.position
        @board.field[post_position[0]][post_position[1]] = nil

        case post_move_piece.color
        when 'white'
            index = @player1.pieces.index(post_move_piece)
            piece = @player1.pieces[index]
            piece.position = pre_move_piece.position
            piece.moved = pre_move_piece.moved
        when 'black'
            index = @player2.pieces.index(post_move_piece)
            piece = @player2.pieces[index]
            piece.position = pre_move_piece.position
            piece.moved = pre_move_piece.moved
        end

        set_board 
        @state.delete(state)
    end

    def move(piece, new_position)
        old_position = piece.position
        state = [piece.dup]
        taken_piece = @board.field[new_position[0]][new_position[1]]
        state << taken_piece.dup
        @state << state
        @board.field[old_position[0]][old_position[1]] = nil
        if piece.class.name == 'Pawn'
            case piece.color
            when 'white'
                piece.en_passant = piece.position[0]-2 == new_position[0] ? true : false
            when 'black'
                piece.en_passant = piece.position[0]+2 == new_position[0] ? true : false
            end
        end
        piece.move(new_position)
        state << piece
        taken_piece.moved = true if taken_piece
        if taken_piece
            case taken_piece.color
            when 'white'
                @player1.taken << taken_piece
                @player1.pieces.delete(taken_piece)
            when 'black'
                @player2.taken << taken_piece
                @player2.pieces.delete(taken_piece)
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
            moves = piece.valid_moves.select { |space|
                valid = true
                occupant = @board.field[space[0]][space[1]]
                if occupant && occupant.color == piece.color
                    valid = false
                end
                valid
            }
            return moves.include?(position) ? true : false
        end
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