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
        @active_player.check = check? 
        legal_moves = construct_legal_moves
        if legal_moves.empty?
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

    def construct_legal_moves
        legal_moves = {}
        @active_player.pieces.each do |piece|
            legal_moves[piece.class.name] = piece.valid_moves
        end

        #blockages
        legal_moves.each { |piece, moves|
            type = piece.class.superclass.name
            case type
            when "Slider"
                moves.map! do |lane|
                    modified_lane(piece.color, lane)
                end                
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

    def checkmate?
        safe_moves = []
        @active_player.pieces.each do |piece|
            moves = piece.valid_moves.select { |move|
                valid_move?(piece,move)
            }
            moves.select! { |space| 
                move(piece,space)
                safe = !check?
                load_state
                safe
            }

            if piece.class.name == 'Pawn'
                takes = piece.valid_takes.select { |take|
                valid_take?(piece, take)
                }
                
                takes.select! { |space|
                    move(piece, space)
                    safe = !check?
                    load_state
                    safe
                }
            end

            safe_moves += moves
            safe_moves += takes if takes

            safe_moves.empty? ? true : false

        end

    end

    def check?
        king = @active_player.find_pieces("King")
        pawns = @inactive_player.find_pieces("Pawn")
        others = @inactive_player.pieces - pawns
        threats = others.select { |piece| valid_move?(piece, king.position)}
        threats += pawns.select { |piece| valid_take?(piece, king.position)}
        threats.empty? ? false : true
    end

    def unmove(post_move_piece)
        state = @state.select { |state| state[2] == post_move_piece}.flatten
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
                @player2.pieces << @player1.taken.pop
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
        piece.move(new_position)
        state << piece
        taken_piece.moved = true if taken_piece
        if taken_piece
            case taken_piece.color
            when 'white'
                @player1.taken << taken_piece
                puts @player1.pieces.include?(taken_piece)
                @player1.pieces.delete(taken_piece)
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