require_relative './piece'
class Jumper < Piece
    @@MOVES = {
        'King' => [[-1,-1], [-1,0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]],
        'Knight' => [[2,1], [2,-1], [1,2], [1,-2], [-1,2], [-1,-2], [-2,1], [-2,-1]]
    }

    def valid_moves
        moves = @@MOVES[self.class.to_s].map { |move| [move,@position].transpose.map { |x| x.reduce(:+)}}
        valid_moves = moves.select { |move| (move[0] >=0 && move[0] <= 7) && (move[1] >=0 && move[1] <= 7)}
        valid_moves
    end
end