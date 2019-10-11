class Pawn
    @@count = 0
    @@MOVES = [[1,0], [-1,0]]
    @@TAKES = [[1,-1], [1,1], [-1,-1], [-1, 1]]

    attr_accessor :position, :moved #for testing

    def initialize(color)
        @sym = 'P'
        @@count += 1
        @color = color
        @position = @color == 'black' ? [1,@@count-1] : [6,@@count-1]
        @moved = false
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

    def take(position)
        if valid_take?(position)
            @position = position
            @moved = true
            return true
        else
            return false
        end
    end

    def valid_move?(position)
        case @color
        when 'black'
            moves = [@@MOVES[0]]
            moves += [[2,0]] unless @moved
        when 'white'
            moves = [@@MOVES[1]]
            moves += [[-2,0]] unless @moved
        end
        moves.map { |move| [move,@position].transpose.map { |x| x.reduce(:+)}}.include?(position)
    end

    def valid_take?(position)
        case @color
        when 'black'
            takes = @@TAKES[0..1]
        when 'white'
            takes = @@TAKES[2..3]
        end
        takes.map { |take| [take,@position].transpose.map { |x| x.reduce(:+)}}.include?(position)
    end

    def self.reset_count
        @@count = 0
    end
end