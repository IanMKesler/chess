require_relative "../lib/king"
require_relative "../lib/bishop"
require_relative "../lib/knight"
require_relative "../lib/pawn"
require_relative "../lib/rook"
require_relative "../lib/queen"

describe King do
    it 'places in the appropriate starting position' do
        black = King.new('black')
        expect(black.position).to eql([0,4])

        white = King.new('white')
        expect(white.position).to eql([7,4])
    end

    describe "#.move" do
        it 'returns false for an invalid move' do
            king = King.new('black')
            expect(king.move([2,2])).to be false
            expect(king.position).to eql([0,4])
        end

        it 'changes the position and returns true for a valid move' do
            king = King.new('black')
            king.position = [3,5]
            MOVES = [[-1,-1], [-1,0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
            all_moves = MOVES.map { |move| [move,king.position].transpose.map { |x| x.reduce(:+)}}
            all_moves.each do |move|
                expect(king.move(move)).to be true
                expect(king.position).to eql(move)
                king.position = [3,5]
            end         
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

    describe '#.construct_moves' do
        it 'constructs all possible moves' do
            bishop = Bishop.new('black')
            possible_moves = [[1,3], [2,4], [3,5], [4,6] ,[5,7], [1,1], [2,0]]
            expect(bishop.send(:construct_moves)).to eql(possible_moves)
        end
    end

    describe '#.valid_move?' do
        it 'returns true for a valid move' do
            Bishop.reset_count
            bishop = Bishop.new('black')
            possible_moves = [[1,3], [2,4], [3,5], [4,6] ,[5,7], [1,1], [2,0]]
            possible_moves.each do |move|
                expect(bishop.send(:valid_move?, move)).to be true
            end
        end

        it 'returns false for an invalid move' do
            bishop = Bishop.new('black')
            expect(bishop.send(:valid_move?, [0,0])).to be false
        end
    end

    describe "#.move" do
        it 'returns false for an invalid move' do
            Bishop.reset_count
            bishop = Bishop.new('black')
            expect(bishop.move([2,2])).to be false
            expect(bishop.position).to eql([0,2])
        end

        it 'changes the position and returns true for a valid move' do
            Bishop.reset_count
            bishop = Bishop.new('black')
            possible_moves = [[1,3], [2,4], [3,5], [4,6] ,[5,7], [1,1], [2,0]]
            possible_moves.each do |move|
                expect(bishop.move(move)).to be true
                expect(bishop.position).to eql(move)
                bishop.position = [0,2]
            end
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
        
    describe "#.move" do
        it 'returns false for an invalid move' do
            Knight.reset_count
            knight = Knight.new('black')
            expect(knight.move([2,1])).to be false
            expect(knight.position).to eql([0,1])
        end
    
        it 'changes the position and returns true for a valid move' do
            Knight.reset_count
            knight = Knight.new('black')
            possible_moves = [[2,0], [2,2], [1,3]]
            possible_moves.each do |move|
                expect(knight.move(move)).to be true
                expect(knight.position).to eql(move)
                knight.position = [0,1]
            end
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

    describe '#.move' do
        it 'returns false for an invalid move' do
            Pawn.reset_count
            pawn = Pawn.new('black')
            expect(pawn.move([3,3])).to be false
            expect(pawn.position).to eql([1,0])
        end

        it 'returns true for valid moves' do
            Pawn.reset_count
            pawn1 = Pawn.new('black')
            valid_positions = [[3,0], [2,0]]
            valid_positions.each do |position|
                expect(pawn1.move(position)).to be true
                expect(pawn1.position).to eql(position)
                pawn1.position = [1,0]
            end

            Pawn.reset_count
            pawn2 = Pawn.new('white')
            valid_positions = [[4,0], [5,0]]
            valid_positions.each do |position|
                expect(pawn2.move(position)).to be true
                expect(pawn2.position).to eql(position)
                pawn2.position = [6,0]
            end
        end

    end

    describe '#.take' do
        it 'returns false for an invalid take' do
            Pawn.reset_count
            pawn = Pawn.new('black')
            expect(pawn.take([3,3])).to be false
            expect(pawn.position).to eql([1,0])
        end

        it 'returns true for valid takes' do
            Pawn.reset_count
            black_pawn = Pawn.new('black')
            black_pawn.position = [1,1]
            valid_takes = [[2,0], [2,2]]
            valid_takes.each do |take|
                expect(black_pawn.take(take)).to be true
                expect(black_pawn.position).to eql(take)
                black_pawn.position = [1,1]
            end

            white_pawn = Pawn.new('white') 
            valid_takes = [[5,0], [5,2]]
            valid_takes.each do |take|
                expect(white_pawn.take(take)).to be true
                expect(white_pawn.position).to eql(take)
                white_pawn.position = [6,1]
            end
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

    describe "#.move" do
        it 'returns false for an invalid move' do
            Rook.reset_count
            rook = Rook.new('black')
            expect(rook.move([2,2])).to be false
            expect(rook.position).to eql([0,0])
        end

        it 'changes the position and returns true for a valid move' do
            Rook.reset_count
            rook = Rook.new('black')
            possible_moves = [[0,1], [0,2], [0,3], [0,4], [0,5], [0,6], [0,7],
                                [1,0], [2,0], [3,0], [4,0], [5,0], [6,0], [7,0]]  
            possible_moves.each do |move|
                expect(rook.move(move)).to be true
                expect(rook.position).to eql(move)
                rook.position = [0,0]
            end
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

    describe "#.move" do
        it 'returns false for an invalid move' do
            queen = Queen.new('black')
            expect(queen.move([2,2])).to be false
            expect(queen.position).to eql([0,3])
        end

        it 'changes the position and returns true for a valid move' do
            queen = Queen.new('black')
            queen.position = [3,5] #5,f
            all_moves = [[2,5], [1,5], [0,5], [3,6], [3,7], [4,5], [5,5], [6,5], [7,5],
                        [3,4], [3,3], [3,2], [3,1], [3,0], [2,4], [1,3], [0,2], [2,6],
                        [1,7], [4,6], [5,7], [4,4], [5,3], [6,2], [7,1]]
            all_moves.each do |move|
                expect(queen.move(move)).to be true
                expect(queen.position).to eql(move)
                queen.position = [3,5]
            end         
        end
    end
end