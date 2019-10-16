require_relative "../lib/game"
describe Game do
    before do
        allow($stdout).to receive(:write)
    end

    game = Game.new
    game.send(:save_state)

    describe "#.format" do
        it 'returns an array for a valid input' do
            expect(game.send(:format, "a4")).to eql([4,0])
        end

        it 'asks again for an invalid input' do
            game.stub(:gets).and_return(" b\n", " 7\n")
            expect(game.send(:format,"Ab97")).to eql([1,1])            
        end
    end

    describe '#.correct_piece?' do
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
        it 'returns the piece of a valid input' do
            game.stub(:gets).and_return("d1\n")
            expect(game.send(:get_piece).class.to_s).to eql("Queen") 
        end

        it 're-prompts for an invalid input' do
            game.stub(:gets).and_return("a7\n", "b3\n", "f2\n")
            expect(game.send(:get_piece).class.to_s).to eql("Pawn")
        end
    end

    describe '#.find_pieces' do
        it 'returns the king of the given player' do
            expect(game.player1.find_pieces("King").position).to eql([7,4])
            expect(game.player2.find_pieces("King").position).to eql([0,4])
        end

        it 'returns an array of pawns' do
            pawns = game.player1.find_pieces("Pawn")
            pawns.each_with_index do |pawn, index|
                expect(pawn.class.name).to eql("Pawn")
                expect(pawn.position).to eql([6,index])
            end
        end
    end

    describe '#.valid_move?' do
        it 'returns true for a valid move for jumper' do
            expect(game.send(:valid_move?, game.active_player.pieces[6], [4,0])).to be true
            expect(game.send(:valid_move?, game.active_player.pieces[6], [5,0])).to be true
        end

        it 'returns true for a valid move for slider' do
            game.send(:move, game.active_player.pieces[6],[5,1])
            expect(game.send(:valid_move?, game.active_player.pieces[0], [2,0])).to be true
            game.send(:load_state)
        end 

        it 'returns false if not in piece.valid_moves' do
            expect(game.send(:valid_move?, game.active_player.pieces[6], [0,4])).to be false
        end

        it 'returns false for a blocked slider' do
            expect(game.send(:valid_move?, game.active_player.pieces[0], [5,0])).to be false
        end
    end

    describe "#.check?" do
        it 'returns false if active_player is safe' do
            expect(game.send(:check?)).to be false
        end

        it 'returns true if active_player king is threatened by pawn' do
            game.send(:move, game.inactive_player.pieces[6],[6,3])
            expect(game.send(:check?)).to be true
            game.send(:load_state)
        end

        it 'returns true if active_player king is threatened by rook' do
            game.send(:move, game.active_player.pieces[10], [5,0])
            game.send(:move, game.inactive_player.pieces[0],[2,4])
            expect(game.send(:check?)).to be true
            game.send(:load_state)
        end
    end
end