class Bishop
    @@count = 0
    @@MOVES = [[-1, -1], [-1, 1], [1, 1], [1, -1]]

    attr_accessor :position #for testing

    def initialize(color)
        @sym = 'B'
        @@count += 1
        if @@count == 1
            @position = color == 'black' ? [0, 2] : [7, 2]
        else
            @position = color == 'black' ? [0, 5] : [7, 5]
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