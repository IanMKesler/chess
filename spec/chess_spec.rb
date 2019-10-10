require_relative "../lib/king"
require_relative "../lib/bishop"
require_relative "../lib/knight"

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
end
