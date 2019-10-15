class Piece
    @@count = {'Rook' => 0,
               'Knight' => 0,
               'Bishop' => 0,
               'Pawn' => 0,
               'Piece' => 0,
               'King' => 0,
               'Queen' => 0,
            }
    
    attr_reader :sym, :color
    attr_accessor :position, :moved
    
    def initialize(color)
        @position = []
        @@count[self.class.to_s] += 1
        @sym = nil
        @color = color
        @moved = false
    end

    def move(position)
        @position = position
        @moved = true     
    end

    def self.reset_count
        @@count[self.to_s] = 0
    end
end