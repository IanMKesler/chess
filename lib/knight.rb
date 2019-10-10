class Knight
    @@count = 0
    @@MOVES = [[2,1], [2,-1], [1,2], [1,-2], [-1,2], [-1,-2], [-2,1], [-2,-1]]

    attr_accessor :position #for testing

    def initialize(color)
        @sym = 'N'
        @@count += 1
        if @@count == 1
            @position = color == 'black' ? [0, 1] : [7, 1]
        else
            @position = color == 'black' ? [0, 6] : [7, 6]
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
        @@MOVES.map { |move| [move,@position].transpose.map { |x| x.reduce(:+)}}.include?(position)
    end

    def self.reset_count
        @@count = 0
    end    
end