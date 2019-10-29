require_relative "../lib/king"
require_relative "../lib/bishop"
require_relative "../lib/knight"
require_relative "../lib/pawn"
require_relative "../lib/rook"
require_relative "../lib/queen"
require_relative "../lib/piece"

describe Piece do
    piece = Piece.new
    describe '#.move' do
        it 'moves the piece and marks as moved' do
            piece.move([3,3])
            expect(piece.position).to eql([3,3])
            expect(piece.moved).to be true
        end      
    end
end

describe King do
    it 'places in the appropriate starting position' do
        black = King.new('black')
        expect(black.position).to eql([0,4])

        white = King.new('white')
        expect(white.position).to eql([7,4])
    end

    describe "#.valid_moves" do
        it 'returns an array of valid moves from current position' do
            king = King.new('black')
            king.position = [3,5]
            moves = [[2,4], [2,5], [2,6], [3,4], [3,6], [4,4], [4,5], [4,6]]
            expect(king.valid_moves).to eql(moves)
        end
    end
end

describe Bishop do
    it 'places in the appropriate starting position' do
        black1 = Bishop.new('black')
        expect(black1.position).to eql([0,2])

        black2 = Bishop.new('black')
        expect(black2.position).to eql([0,5])

        Bishop.reset_count

        white1 = Bishop.new('white')
        expect(white1.position).to eql([7,2])

        white2 = Bishop.new('white')
        expect(white2.position).to eql([7,5])

        Bishop.reset_count
    end

    describe '#.valid_moves' do
        it 'constructs all possible moves' do
            bishop = Bishop.new('black')
            possible_moves = [[], [], [[1,3], [2,4], [3,5], [4,6] ,[5,7]], [[1,1], [2,0]]]
            expect(bishop.valid_moves).to eql(possible_moves)
        end
    end
end

describe Knight do
    it 'places in the appropriate starting position' do
        black1 = Knight.new('black')
        expect(black1.position).to eql([0,1])
    
        black2 = Knight.new('black')
        expect(black2.position).to eql([0,6])
    
        Knight.reset_count
    
        white1 = Knight.new('white')
        expect(white1.position).to eql([7,1])
    
        white2 = Knight.new('white')
        expect(white2.position).to eql([7,6])
    end
        
    describe '#.valid_moves' do
        it 'returns an array of possible moves' do
            Knight.reset_count
            knight = Knight.new('black')
            possible_moves = [[2,2], [2,0], [1,3]]
            expect(knight.valid_moves).to eql(possible_moves)
        end
    end
end

describe Pawn do
    it 'places in the appropriate starting position' do
        black_pawns = []
        8.times do |i|
            black_pawns << Pawn.new('black')
            expect(black_pawns[-1].position).to eql([1,i])
        end

        Pawn.reset_count

        white_pawns = []
        8.times do |i|
            white_pawns << Pawn.new('white')
            expect(white_pawns[-1].position).to eql([6,i])
        end
    end

    describe '#.valid_moves' do
        it 'returns an array of valid moves' do
            Pawn.reset_count
            pawn1 = Pawn.new('black')
            valid_moves = [[2,0], [3,0]]
            expect(pawn1.valid_moves).to eql(valid_moves)

            Pawn.reset_count
            pawn2 = Pawn.new('white')
            valid_moves = [[5,0], [4,0]]
            expect(pawn2.valid_moves).to eql(valid_moves)
        end

    end

    describe '#.valid_takes' do
        it 'returns true for valid takes' do
            Pawn.reset_count
            black_pawn = Pawn.new('black')
            black_pawn.position = [1,1]
            valid_takes = [[2,0], [2,2]]
            expect(black_pawn.valid_takes).to eql(valid_takes)

            white_pawn = Pawn.new('white') 
            valid_takes = [[5,0], [5,2]]
            expect(white_pawn.valid_takes).to eql(valid_takes)
        end
    end
end

describe Rook do
    it 'places in the appropriate starting position' do
        black_rooks = []
        2.times do |i|
            black_rooks << Rook.new('black')
            expect(black_rooks[-1].position).to eql([0,i*7])
        end

        Rook.reset_count

        white_rooks = []
        2.times do |i|
            white_rooks << Rook.new('white')
            expect(white_rooks[-1].position).to eql([7,i*7])
        end
    end

    describe '#.valid_moves' do
        it 'returns an array of valid moves' do
            Rook.reset_count
            rook = Rook.new('black')
            possible_moves = [[],[[0,1], [0,2], [0,3], [0,4], [0,5], [0,6], [0,7]],
                              [[1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0]], []]
            expect(rook.valid_moves).to eql(possible_moves)
        end
    end
end

describe Queen do
    it 'places in the appropriate starting position' do
        black = Queen.new('black')
        expect(black.position).to eql([0,3])

        white = Queen.new('white')
        expect(white.position).to eql([7,3])
    end

    describe "#.valid_moves" do
        it 'returns an array of valid moves' do
            queen = Queen.new('black')
            possible_moves = [[], [[0,4], [0,5], [0,6], [0,7]], 
                              [[1,3], [2,3], [3,3], [4,3], [5,3], [6,3], [7,3]],
                              [[0,2], [0,1], [0,0]], [], [],
                              [[1,4], [2,5], [3,6], [4,7]],
                              [[1,2], [2,1], [3,0]]]
            expect(queen.valid_moves).to eql(possible_moves)
        end
    end
end