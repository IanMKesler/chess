class King
    @@MOVES = [[-1,-1], [-1,0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]

    attr_accessor :position #for testing

    def initialize(color)
        @sym = 'K'
        @position = color == 'black' ? [0,4] : [7,4]
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
end