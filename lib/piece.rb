class Piece
    @@count = {'Rook' => 0,
               'Knight' => 0,
               'Bishop' => 0,
               'Pawn' => 0}
    
    def initialize
        @position = []
        @@count[self.class.to_s] += 1
    end

    def move(position)
        if valid_move?(position)
            @position = position
            @moved = true
            return true
        else
            return false
        end
    end

    def valid_move?(position)
        true
    end

    def self.reset_count
        @@count[self.to_s] = 0
    end
end