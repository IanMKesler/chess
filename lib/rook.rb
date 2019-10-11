class Rook
    @@count = 0
    @@MOVES = [[-1,0], [0,1], [1,0], [0,-1]]

    attr_accessor :position #for testing

    def initialize(color)
        @sym = 'R'
        @@count += 1
        case @@count
        when 1
            @position = color == 'black' ? [0,0] : [7,0]
        when 2
            @position = color == 'black' ? [0,7] : [7,7]
        end
    end

    def move(position)
        if valid_move?(position)
            @position = position 
            return true
        else
            return false
        end
    end

    def valid_move?(position)
        moves = construct_moves
        moves.include?(position)
    end

    def self.reset_count
        @@count = 0
    end

    private

    def construct_moves
        moves = []
        @@MOVES.each do |move|
            new_position = [move,@position].transpose.map { |x| x.reduce(:+)}
            on_board = (new_position[0] >=0 && new_position[0] <= 7) && (new_position[1] >=0 && new_position[1] <= 7)
            while on_board
                moves << new_position
                new_position = [move,new_position].transpose.map { |x| x.reduce(:+)}
                on_board = (new_position[0] >=0 && new_position[0] <= 7) && (new_position[1] >=0 && new_position[1] <= 7)
            end
        end
        moves
    end

end