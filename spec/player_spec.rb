require_relative "../lib/player"

describe Player do
    describe 'Black' do
        black = Player.new('black')
        rooks = black.pieces.select { |piece| piece.class.name == 'Rook'}
        knights = black.pieces.select { |piece| piece.class.name == 'Knight'}
        bishops = black.pieces.select { |piece| piece.class.name == 'Bishop'}
        pawns = black.pieces.select { |piece| piece.class.name == 'Pawn'}
        queens = black.pieces.select { |piece| piece.class.name == 'Queen'}
        kings = black.pieces.select { |piece| piece.class.name == 'King'}
    
        it 'assigns the correct pieces for black' do
            expect(rooks.length).to eql(2)
            expect(knights.length).to eql(2)
            expect(bishops.length).to eql(2)
            expect(pawns.length).to eql(8)
            expect(queens.length).to eql(1)
            expect(kings.length).to eql(1)
        end
    
        it 'assigns the correct starting positions for black' do
            rooks.each_with_index do |rook,index|
                expect(rook.position).to eql([0,7*index])
            end
            knights.each_with_index do |knight,index|
                expect(knight.position).to eql([0,1+5*index])
            end
            bishops.each_with_index do |bishop,index|
                expect(bishop.position).to eql([0,2+3*index])
            end
            pawns.each_with_index do |pawn, index|
                expect(pawn.position).to eql([1,index])
            end
            expect(queens[0].position).to eql([0,3])
            expect(kings[0].position).to eql([0,4])
        end
    end

    describe 'White' do
        white = Player.new('white')
        rooks = white.pieces.select { |piece| piece.class.name == 'Rook'}
        knights = white.pieces.select { |piece| piece.class.name == 'Knight'}
        bishops = white.pieces.select { |piece| piece.class.name == 'Bishop'}
        pawns = white.pieces.select { |piece| piece.class.name == 'Pawn'}
        queens = white.pieces.select { |piece| piece.class.name == 'Queen'}
        kings = white.pieces.select { |piece| piece.class.name == 'King'}
    
        it 'assigns the correct pieces for white' do
            expect(rooks.length).to eql(2)
            expect(knights.length).to eql(2)
            expect(bishops.length).to eql(2)
            expect(pawns.length).to eql(8)
            expect(queens.length).to eql(1)
            expect(kings.length).to eql(1)
        end
    
        it 'assigns the correct starting positions for white' do
            rooks.each_with_index do |rook,index|
                expect(rook.position).to eql([7,7*index])
            end
            knights.each_with_index do |knight,index|
                expect(knight.position).to eql([7,1+5*index])
            end
            bishops.each_with_index do |bishop,index|
                expect(bishop.position).to eql([7,2+3*index])
            end
            pawns.each_with_index do |pawn, index|
                expect(pawn.position).to eql([6,index])
            end
            expect(queens[0].position).to eql([7,3])
            expect(kings[0].position).to eql([7,4])
        end
    end
end