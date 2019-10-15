require_relative "../lib/game"
describe Game do
    before do
        allow($stdout).to receive(:write)
    end

    describe "#.format" do
        game = Game.new
        it 'returns an array for a valid input' do
            expect(game.send(:format, "a4")).to eql([4,0])
        end

        it 'asks again for an invalid input' do
            game.stub(:gets).and_return(" b\n", " 7\n")
            expect(game.send(:format,"Ab97")).to eql([1,1])            
        end
    end

    describe '#.correct_piece?' do
        game = Game.new
        game.send(:set_board)
        it 'returns true when selecting one of your pieces' do
            expect(game.send(:correct_piece?,[7,0])).to be true
        end 

        it 'returns false when selecting an opponenets piece' do
            expect(game.send(:correct_piece?,[0,0])).to be false
        end

        it 'returns false when no piece is selected' do
            expect(game.send(:correct_piece?,[3,3])).to be false
        end
    end

    describe '#.get_piece' do
        game = Game.new
        it 'returns the piece of a valid input' do
            game.stub(:gets).and_return("d1\n")
            expect(game.send(:get_piece).class.to_s).to eql("Queen") 
        end

        it 're-prompts for an invalid input' do
            game.stub(:gets).and_return("a7\n", "b3\n", "f2\n")
            expect(game.send(:get_piece).class.to_s).to eql("Pawn")
        end
    end
end