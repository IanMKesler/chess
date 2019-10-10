require_relative "../lib/king"
describe King do
    describe "#.move" do
        it 'places in the appropriate starting position' do
            black = King.new('black')
            expect(black.position).to eql([0,4])

            white = King.new('white')
            expect(white.position).to eql([7,4])
        end

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