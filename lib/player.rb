class Player
    require_relative "./rook"
    require_relative "./knight"
    require_relative "./bishop"
    require_relative "./pawn"
    require_relative "./queen"
    require_relative "./king"

    attr_accessor :check, :checkmate, :pieces, :taken, :computer
    attr_reader :color

    def initialize(color)
        @color = color
        @pieces = []
        2.times do 
            @pieces << Rook.new(color)
            @pieces << Knight.new(color)
            @pieces << Bishop.new(color)
        end
        8.times do
            @pieces << Pawn.new(color)
        end
        @pieces << Queen.new(color)
        @pieces << King.new(color)

        reset_counts

        @check = false
        @checkmate = false
        @taken = []
        @computer = false
    end

    def find_pieces(piece_name)
        pieces = @pieces.select { |piece| piece.class.name == piece_name}
        pieces.length > 1 ? pieces : pieces[0]
    end

    def find_piece(position)
        output = @pieces.select { |piece| piece.position == position}
        output[0]
    end

    private

    def reset_counts
        Rook.reset_count
        Knight.reset_count
        Bishop.reset_count
        Pawn.reset_count
    end
end