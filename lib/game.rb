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
        reset_en_passant
        opponent_moves = construct_legal_moves(@inactive_player)
        legal_moves = construct_legal_moves(@active_player)
        @active_player.check = check?(opponent_moves)
        puts "#{@active_player.color} is in check!" if @active_player.check
        return false if no_moves?(legal_moves)
        case @active_player.computer
        when false
            choice = player_round(legal_moves)
        when true
            choice = computer_round(legal_moves)
        end
        return choice if choice.is_a?(String)
        move(choice[0], choice[1])
        @active_player, @inactive_player = @inactive_player, @active_player
        return true
    end

    private 

    def computer_round(legal_moves)
        piece = random_piece(legal_moves)
        space = random_move(legal_moves, piece)
        return [piece,space]        
    end

    def player_round(legal_moves)
        puts "To quit at any time, input 'q'. To save and quit, input 's'"
        piece = get_piece
        return piece if save_quit?(piece)
        while legal_moves[piece].empty?
            puts "That piece can't move! Choose another."
            piece = get_piece
            return piece if save_quit?(piece)
        end
        space = get_move(piece, legal_moves)
        return space if save_quit?(space)
        until legal_moves[piece].include?(space)
            puts "That's an invalid move! Try again."
            puts "Your King is still in check!" if @active_player.check
            piece = get_piece
            return piece if save_quit?(piece)
            space = get_move(piece)
            return space if save_quit?(piece)
        end
        return [piece,space]       
    end

    def random_piece(legal_moves)
        pieces =legal_moves.select { |piece,moves| !moves.empty?}.keys
        pieces.sample
    end

    def random_move(legal_moves, piece)
        moves = legal_moves[piece]
        moves.sample
    end

    def reset_en_passant
        pawns = @active_player.find_pieces("Pawn")
        pawns.each do |pawn|
            pawn.en_passant = false
        end
    end

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

    def en_passant?(pawn, opponent)
        opponent.class.name == 'Pawn' && opponent.color != pawn.color && opponent.en_passant
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
                    legal_moves[pawn] << take if en_passant?(pawn, opponent)
                when 'black'
                    opponent = @board.field[take[0]-1][take[1]]
                    legal_moves[pawn] << take if en_passant?(pawn, opponent)
                end
            end
        end
        legal_moves
    end

    def castle_side(king, rook)
        king.position[1] > rook.position[1] ? 'Queen' : 'King' 
    end


    def castle_move(king, rook)
        row = king.position[0]
        side = castle_side(king, rook)
        case side
        when 'Queen'
            return [row, 2]
        when 'King'
            return [row, 6]
        end
    end

    def castle_clear?(row, columns)
        columns.each do |column|
            return false if @board.field[row][column]
        end
        return true
    end

    def castle_threatened?(king, row, columns)
        columns.each do |column|
            move(king, [row,column])
            opponent_moves = construct_legal_moves(@inactive_player)
            threatened = check?(opponent_moves)
            unmove(king)
            return true if threatened
        end
        return false
    end

    def construct_castle_columns(king, rook)
        side = castle_side(king, rook)
        case side
        when 'Queen' 
            between = (rook.position[1]+1...king.position[1]).to_a
            king_moves = between[-2..-1]
        when 'King' 
            between = (king.position[1]+1...rook.position[1]).to_a
            king_moves = between[0..1]
        end
        [between, king_moves]
    end

    def castle?(king, rook)
        row = king.position[0]
        parameters = construct_castle_columns(king, rook)
        between = parameters[0]
        king_moves = parameters[1]
        valid = castle_clear?(row, between) && !castle_threatened?(king, row, king_moves)
    end

    def add_castles(legal_moves)
        castles = []
        king = @active_player.find_pieces("King")
        rooks = @active_player.find_pieces("Rook")
        disqualified = king.moved || rooks.select{ |rook| rook.moved == false}.length == 0
        return legal_moves if disqualified
        rooks.each do |rook|
            castles << castle_move(king, rook) if castle?(king, rook)
        end 
        legal_moves[king] += castles
        legal_moves
    end

    def non_check_moves(piece, moves)
        moves.select { |space|
            move(piece,space)
            opponent_moves = construct_legal_moves(@inactive_player)
            valid = check?(opponent_moves) ? false : true
            unmove(piece)
            valid
        }
    end

    def remove_check_moves(legal_moves)
        legal_moves.map { |piece, moves|
            [piece, non_check_moves(piece, moves)]
        }.to_h
    end

    def pawn_takes(pawn)
        takes = []
        pawn.valid_takes.each do |take|
            opponent = @board.field[take[0]][take[1]]
            if opponent && opponent.color != pawn.color
                takes << take
            end
        end
        takes
    end

    def add_pawn_takes(legal_moves)
        legal_moves.map {|piece, moves|
            is_pawn = piece.class.name == "Pawn" 
            new_moves = is_pawn ? moves + pawn_takes(piece) : moves
            [piece, new_moves]
        }.to_h
    end

    def open_spaces(piece, moves)
        type = piece.class.superclass.name
        case type
        when "Slider"
            new_moves = moves.map { |lane|
                modified_lane(piece.color, lane)
            }.flatten(1)
        when "Piece"
            open = true
            new_moves = moves.select { |space|
                open = false if @board.field[space[0]][space[1]]
                open
            }
        when "Jumper"
            new_moves = moves.select { |space|
                occupant = @board.field[space[0]][space[1]]
                occupied = occupant && occupant.color == piece.color
                !occupied
            }
        end
        new_moves
    end

    def remove_blocks(legal_moves)
        legal_moves.map { |piece, moves|
            new_moves = open_spaces(piece, moves)
            [piece, new_moves]
        }.to_h
    end

    def modified_lane(color,lane)
        lane.each_with_index do |position, index|
            if @board.field[position[0]][position[1]]
                same_side = @board.field[position[0]][position[1]].color == color
                case same_side
                when true
                    lane = lane[0...index]
                    break
                when false
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
        return false if state.empty? #throws error nil.empty?
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

        #unmove rook for castle
        if state.length == 5
            pre_castle = state[3]
            post_castle = state[4]

            post_position = post_castle.position

            @board.field[post_position[0]][post_position[1]] = nil

            case post_castle.color
            when 'white'
                index = @player1.pieces.index(post_castle)
                piece = @player1.pieces[index]
                piece.position = pre_castle.position
                piece.moved = pre_castle.moved
            when 'black'
                index = @player2.pieces.index(post_castle)
                piece = @player2.pieces[index]
                piece.position = pre_castle.position
                piece.moved = pre_castle.moved
            end
        end

        set_board 
        @state.delete(state)
    end

    def move(piece, new_position)
        old_piece = piece.dup
        taken_piece = @board.field[new_position[0]][new_position[1]]
        old_position = piece.position
        @board.field[old_position[0]][old_position[1]] = nil     
        if piece.class.name == "King" && piece.moved == false
            castle_states = move_castle(piece, new_position)
        end
        if piece.class.name == 'Pawn'
            if piece.valid_takes.include?(new_position)
                taken_piece = en_passant_take(old_position, piece, taken_piece)
            end
            set_en_passant(piece, new_position)
        end
        piece.move(new_position)
        new_piece = piece
        state = construct_state(old_piece, taken_piece, new_piece, castle_states)
        @state << state
        if taken_piece
            take_piece(taken_piece)
        end
        set_board
    end

    def take_piece(taken_piece)
        taken_piece.moved = true
        case taken_piece.color
        when 'white'
            @player1.taken << taken_piece
            @player1.pieces.delete(taken_piece)
        when 'black'
            @player2.taken << taken_piece
            @player2.pieces.delete(taken_piece)
        end
    end

    def set_en_passant(piece, new_position)
        case piece.color
        when 'white'
            piece.en_passant = piece.position[0]-2 == new_position[0] ? true : false
        when 'black'
            piece.en_passant = piece.position[0]+2 == new_position[0] ? true : false
        end
    end

    def en_passant_take(old_position, piece, taken_piece)
        en_passant_positions = [[old_position[0], old_position[1]-1], [old_position[0], old_position[1]+1]]
        en_passant_positions.each do |position|
            opponent = @board.field[position[0]][position[1]] 
            if opponent && en_passant?(piece,opponent)
                taken_piece = opponent
                @board.field[position[0]][position[1]] = nil
            end
        end
        taken_piece
    end

    def construct_state(old_piece, taken_piece, new_piece, castle_states)
        state = [old_piece, taken_piece.dup, new_piece]
        state << castle_states if castle_states
        state.flatten(1)
    end

    def move_castle(king, new_position)
        pre_castle = nil
        post_castle = nil
        case king.color
        when 'white'
            case new_position
            when [7,2]
                castle = @board.field[7][0]
                pre_castle = castle.dup
                castle.move([7,3])
                post_castle = castle
                @board.field[7][0] = nil
            when [7,6]
                castle = @board.field[7][7]
                pre_castle = castle.dup
                castle.move([7,5])
                post_castle = castle
                @board.field[7][7] = nil
            else
                return false
            end
        when 'black'
            case new_position
            when [0,2]
                castle = @board.field[0][0]
                pre_castle = castle.dup
                castle.move([0,3])
                post_castle = castle
                @board.field[0][0] = nil
            when [0,6]
                castle = @board.field[0][7]
                pre_castle = castle.dup
                castle.move([0,5])
                post_castle = castle
                @board.field[0][7] = nil
            else
                return false
            end
        end
        return [pre_castle, post_castle]
    end


    def get_move(piece, legal_moves)
        puts "Move #{@active_player.color} #{piece.class.to_s} to:"
        input = format(gets.strip)
        return input if save_quit?(input)
        until legal_moves[piece].include?(input)
            puts "Not a valid move for that piece, try again."
            input = format(gets.strip)
            return input if save_quit?(input)
        end
        input
    end

    def set_player(player)
        player.pieces.each do |piece|
            row = piece.position[0]
            column = piece.position[1]
            @board.field[row][column] = piece
        end
    end

    def set_board
        set_player(@player1)
        set_player(@player2)
    end

    def get_piece
        puts "#{@active_player.color}: Select piece"
        input = format(gets.strip)
        return input if save_quit?(input)
        until correct_piece?(input)
            puts "Please select a #{@active_player.color} piece on the board."
            input = format(gets.strip)
            return input if save_quit?(input)
        end
        @board.field[input[0]][input[1]]
    end

    def correct_piece?(input)
        piece = @board.field[input[0]][input[1]]
        @active_player.pieces.include?(piece)
    end

    def save_quit?(input)
        return false unless input.is_a?(String)
        return input.match(/\A[QqSs]\z/) ? true : false 
    end

    def format(input)
        return input if save_quit?(input)
        split = input.downcase.split("")
        column = split.select { |char| char.match(/[a-h]/)}.flatten
        row = split.select { |num| num.match(/[1-8]/)}.flatten
        until column.length == 1
            puts "Which column did you mean? [a-h]"
            column = gets.strip.downcase.split("").select {|char| char.match(/[a-h]/)}.flatten
            return column if save_quit?(column)
        end
        until row.length == 1
            puts "Which row did you mean? [1-8]"
            row = gets.strip.downcase.split("").select {|num| num.match(/[1-8]/)}.flatten
            return row if save_quit?(row)
        end
        output = [7-(row[0].to_i-1),board.column_reference.key(column[0])]
        output
    end
end