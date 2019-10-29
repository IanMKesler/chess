require_relative "./piece"
class Slider < Piece
    @@MOVES = {'Rook' => [[-1,0], [0,1], [1,0], [0,-1]],
               'Bishop' => [[-1, -1], [-1, 1], [1, 1], [1, -1]],
               'Queen' => [[-1,0], [0,1], [1,0], [0,-1], [-1, -1], [-1, 1], [1, 1], [1, -1]]}

    def valid_moves
        moves = []
        @@MOVES[self.class.to_s].each do |move|
            lane = []
            new_position = [move,@position].transpose.map { |x| x.reduce(:+)}
            on_board = (new_position[0] >=0 && new_position[0] <= 7) && (new_position[1] >=0 && new_position[1] <= 7)
            while on_board
                lane << new_position
                new_position = [move,new_position].transpose.map { |x| x.reduce(:+)}
                on_board = (new_position[0] >=0 && new_position[0] <= 7) && (new_position[1] >=0 && new_position[1] <= 7)
            end
            moves << lane
        end
        moves
    end
end