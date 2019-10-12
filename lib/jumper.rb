require_relative './piece'
class Jumper < Piece
    @@MOVES = {
        'King' => [[-1,-1], [-1,0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
        'Knight' => [[2,1], [2,-1], [1,2], [1,-2], [-1,2], [-1,-2], [-2,1], [-2,-1]]
    }

    def valid_move?(position)
        @@MOVES[self.class.to_s].map { |move| [move,@position].transpose.map { |x| x.reduce(:+)}}.include?(position)
    end
end