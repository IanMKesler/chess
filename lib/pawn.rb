require_relative "./jumper"
class Pawn < Piece
    @@MOVES = [[1,0], [-1,0]]
    @@TAKES = [[1,-1], [1,1], [-1,-1], [-1, 1]]

    attr_accessor :position, :moved #for testing

    def initialize(color)
        super(color)
        @sym = color == 'black' ? "\u2659" : "\u265F"
        count = @@count[self.class.to_s]
        @position = @color == 'black' ? [1,count-1] : [6,count-1]
    end

    def valid_moves
        case @color
        when 'black'
            moves = [@@MOVES[0]]
            moves += [[2,0]] unless @moved
        when 'white'
            moves = [@@MOVES[1]]
            moves += [[-2,0]] unless @moved
        end
        possible_moves = moves.map { |move| [move,@position].transpose.map { |x| x.reduce(:+)}}
        valid_moves = possible_moves.select { |move| (move[0] >=0 && move[0] <= 7) && (move[1] >=0 && move[1] <= 7)}
    end

    def valid_takes
        case @color
        when 'black'
            takes = @@TAKES[0..1]
        when 'white'
            takes = @@TAKES[2..3]
        end
        takes.map { |take| [take,@position].transpose.map { |x| x.reduce(:+)}}
    end
end