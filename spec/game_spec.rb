require_relative "../lib/game"
describe Game do
    before do
        allow($stdout).to receive(:write)
    end

    game = Game.new

    describe "#.format" do
        it 'returns an array for a valid input' do
            expect(game.send(:format, "a4")).to eql([4,0])
        end

        it 'asks again for an invalid input' do
            game.stub(:gets).and_return(" b\n", " 7\n")
            expect(game.send(:format,"Ab97")).to eql([1,1])            
        end

        it 'returns input if given "q" or "s"' do
            inputs = ["q", "s"]
            inputs.each do |input|
                expect(game.send(:format,input)).to eql(input)
            end
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
            #game.board.show
            expect(game.send(:get_piece).class.to_s).to eql("Pawn")
        end

        it 'returns input if given "q" or "s"' do
            game.stub(:gets).and_return("q", "s")
            inputs = ["q", "s"]
            inputs.each do |input|
                expect(game.send(:get_piece)).to eql(input)
            end
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
            game.send(:unmove, game.active_player.pieces[6])
            
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
            opponent_moves = game.send(:construct_legal_moves, game.inactive_player)
            expect(game.send(:check?, opponent_moves)).to be false
        end


        it 'returns true if active_player king is threatened by pawn' do
            game.send(:move, game.inactive_player.pieces[6],[6,3])
            opponent_moves = game.send(:construct_legal_moves, game.inactive_player)
            expect(game.send(:check?, opponent_moves)).to be true
            game.send(:unmove, game.inactive_player.pieces[6])
            
                     
        end

        it 'returns true if active_player king is threatened by rook' do
            pawn = game.active_player.find_piece([6,4])
            game.send(:move, pawn, [5,0])
            rook = game.inactive_player.find_piece([0,0])
            game.send(:move, rook,[2,4])
            opponent_moves = game.send(:construct_legal_moves, game.inactive_player)
            expect(game.send(:check?, opponent_moves)).to be true
            game.send(:unmove, rook)
            game.send(:unmove, pawn)            
        end
    end
    
    describe '#.modified_lane' do
        it 'returns a shortened lane if blocked' do
            lane = game.player1.find_piece([7,0]).valid_moves[0]
            expect(game.send(:modified_lane, game.player1.color,lane)).to eql([])
            
            pawn1 = game.player1.find_piece([6,0])
            pawn2 = game.player2.find_piece([1,0])
            game.send(:move, pawn1, [5,1])
            game.send(:move, pawn2, [5,2])
            
            valid = [[6,0], [5,0], [4,0], [3,0], [2,0], [1,0], [0,0]]
            expect(game.send(:modified_lane, game.player1.color, lane)).to eql (valid)
            game.send(:unmove, pawn2)
            game.send(:unmove, pawn1)
            
        end
    end

    describe '#.remove_blocks' do
        it 'returns a modified hash with blocked spaces removed' do
            black_pawn1 = game.player2.find_piece([1,5])
            black_pawn2 = game.player2.find_piece([1,0])
            game.send(:move, black_pawn1, [5,0])
            game.send(:move, black_pawn2, [4,2])
            legal_moves = {}
            game.active_player.pieces.each do |piece|
                legal_moves[piece] = piece.valid_moves
            end
            #game.board.show
            legal_moves = game.send(:remove_blocks,legal_moves)
            expected_moves = {
                game.active_player.find_piece([7,0]) => [],
                game.active_player.find_piece([7,7]) => [],
                game.active_player.find_piece([7,1]) => [[5,2], [5,0]],
                game.active_player.find_piece([7,6]) => [[5,7], [5,5]],
                game.active_player.find_piece([7,2]) => [],
                game.active_player.find_piece([7,5]) => [],
                game.active_player.find_piece([7,3]) => [],
                game.active_player.find_piece([7,4]) => [],
                game.active_player.find_piece([6,0]) => [],
                game.active_player.find_piece([6,1]) => [[5,1], [4,1]],
                game.active_player.find_piece([6,2]) => [[5,2]],
                game.active_player.find_piece([6,3]) => [[5,3], [4,3]],
                game.active_player.find_piece([6,4]) => [[5,4], [4,4]],
                game.active_player.find_piece([6,5]) => [[5,5], [4,5]],
                game.active_player.find_piece([6,6]) => [[5,6], [4,6]],
                game.active_player.find_piece([6,7]) => [[5,7], [4,7]]
            }

            expected_moves.each do |piece, moves|
                expect(legal_moves[piece]).to eql(moves)
            end

            game.send(:unmove, black_pawn2)
            game.send(:unmove, black_pawn1)
        end
    end

    describe '#.add_pawn_takes' do
        it 'adds valid pawn takes' do
            pawns = game.active_player.find_pieces("Pawn")
            pawns.each_with_index do |pawn, index|
                game.send(:move, pawn, [2,index])
            end
            legal_moves = {}
            game.active_player.pieces.each do |piece|
                legal_moves[piece] = piece.valid_moves
            end

            legal_moves = game.send(:remove_blocks,legal_moves)
            legal_moves = game.send(:add_pawn_takes, legal_moves)
            expected_moves = {
                game.active_player.find_piece([7,0]) => [[6,0], [5,0], [4,0], [3,0]],
                game.active_player.find_piece([7,7]) => [[6,7], [5,7], [4,7], [3,7]],
                game.active_player.find_piece([7,1]) => [[6,3], [5,2], [5,0]],
                game.active_player.find_piece([7,6]) => [[6,4], [5,7], [5,5]],
                game.active_player.find_piece([7,2]) => [[6,1], [5,0], [6,3], [5,4], [4,5], [3,6]],
                game.active_player.find_piece([7,5]) => [[6,4], [5,3], [4,2], [3,1], [6,6], [5,7]],
                game.active_player.find_piece([7,3]) => [[6,3], [5,3], [4,3], [3,3], [6,2], [5,1], [4,0],
                                                         [6,4], [5,5], [4,6], [3,7]],
                game.active_player.find_piece([7,4]) => [[6,3], [6,4], [6,5]],
                game.active_player.find_piece([2,0]) => [[1,1]],
                game.active_player.find_piece([2,1]) => [[1,0], [1,2]],
                game.active_player.find_piece([2,2]) => [[1,1], [1,3]],
                game.active_player.find_piece([2,3]) => [[1,2], [1,4]],
                game.active_player.find_piece([2,4]) => [[1,3], [1,5]],
                game.active_player.find_piece([2,5]) => [[1,4], [1,6]],
                game.active_player.find_piece([2,6]) => [[1,5], [1,7]],
                game.active_player.find_piece([2,7]) => [[1,6]]
            }

            expected_moves.each do |piece, moves|
                expect(legal_moves[piece]).to eql(moves)
            end
            pawns.each_with_index do |pawn, index|
                game.send(:unmove, pawn)
            end
        end
    end

    describe '#.remove_check_moves' do
        it 'removes nothing if no check moves' do
            legal_moves = {}
            game.active_player.pieces.each do |piece|
                legal_moves[piece] = piece.valid_moves
            end

            legal_moves = game.send(:remove_blocks,legal_moves)
            legal_moves = game.send(:add_pawn_takes, legal_moves)
            legal_moves = game.send(:remove_check_moves,legal_moves)
            
            expected_moves = {
                game.active_player.find_piece([7,0]) => [],
                game.active_player.find_piece([7,7]) => [],
                game.active_player.find_piece([7,1]) => [[5,2], [5,0]],
                game.active_player.find_piece([7,6]) => [[5,7], [5,5]],
                game.active_player.find_piece([7,2]) => [],
                game.active_player.find_piece([7,5]) => [],
                game.active_player.find_piece([7,3]) => [],
                game.active_player.find_piece([7,4]) => [],
                game.active_player.find_piece([6,0]) => [[5,0], [4,0]],
                game.active_player.find_piece([6,1]) => [[5,1], [4,1]],
                game.active_player.find_piece([6,2]) => [[5,2], [4,2]],
                game.active_player.find_piece([6,3]) => [[5,3], [4,3]],
                game.active_player.find_piece([6,4]) => [[5,4], [4,4]],
                game.active_player.find_piece([6,5]) => [[5,5], [4,5]],
                game.active_player.find_piece([6,6]) => [[5,6], [4,6]],
                game.active_player.find_piece([6,7]) => [[5,7], [4,7]]
            }

            expected_moves.each do |piece, moves|
                expect(legal_moves[piece]).to eql(moves)
            end
        end

        it 'removes moves that lead to check' do
            bishop = game.player2.find_piece([0,2])
            game.send(:move, bishop, [3,0])
            
            legal_moves = {}
            game.active_player.pieces.each do |piece|
                legal_moves[piece] = piece.valid_moves
            end

            legal_moves = game.send(:remove_blocks,legal_moves)
            legal_moves = game.send(:add_pawn_takes, legal_moves)
            legal_moves = game.send(:remove_check_moves,legal_moves)
            
            expected_moves = {
                game.active_player.find_piece([7,0]) => [],
                game.active_player.find_piece([7,7]) => [],
                game.active_player.find_piece([7,1]) => [[5,2], [5,0]],
                game.active_player.find_piece([7,6]) => [[5,7], [5,5]],
                game.active_player.find_piece([7,2]) => [],
                game.active_player.find_piece([7,5]) => [],
                game.active_player.find_piece([7,3]) => [],
                game.active_player.find_piece([7,4]) => [],
                game.active_player.find_piece([6,0]) => [[5,0], [4,0]],
                game.active_player.find_piece([6,1]) => [[5,1], [4,1]],
                game.active_player.find_piece([6,2]) => [[5,2], [4,2]],
                game.active_player.find_piece([6,3]) => [],
                game.active_player.find_piece([6,4]) => [[5,4], [4,4]],
                game.active_player.find_piece([6,5]) => [[5,5], [4,5]],
                game.active_player.find_piece([6,6]) => [[5,6], [4,6]],
                game.active_player.find_piece([6,7]) => [[5,7], [4,7]]
            }

            expected_moves.each do |piece, moves|
                expect(legal_moves[piece]).to eql(moves)
            end

            game.send(:unmove, bishop)
        end

        it 'removes moves that leave active player in check' do
            pawn = game.player2.find_piece([1,3])
            game.send(:move, pawn, [6,3])


            legal_moves = {}
            game.active_player.pieces.each do |piece|
                legal_moves[piece] = piece.valid_moves
            end

            legal_moves = game.send(:remove_blocks,legal_moves)
            legal_moves = game.send(:add_pawn_takes, legal_moves)
            legal_moves = game.send(:remove_check_moves,legal_moves)
            
            expected_moves = {
                game.active_player.find_piece([7,0]) => [],
                game.active_player.find_piece([7,7]) => [],
                game.active_player.find_piece([7,1]) => [[6,3]],
                game.active_player.find_piece([7,6]) => [],
                game.active_player.find_piece([7,2]) => [[6,3]],
                game.active_player.find_piece([7,5]) => [],
                game.active_player.find_piece([7,3]) => [[6,3]],
                game.active_player.find_piece([7,4]) => [],
                game.active_player.find_piece([6,0]) => [],
                game.active_player.find_piece([6,1]) => [],
                game.active_player.find_piece([6,2]) => [],
                game.active_player.find_piece([6,4]) => [],
                game.active_player.find_piece([6,5]) => [],
                game.active_player.find_piece([6,6]) => [],
                game.active_player.find_piece([6,7]) => []
            }

            expected_moves.each do |piece, moves|
                expect(legal_moves[piece]).to eql(moves)
            end

            game.send(:unmove, pawn)
        end
    end

    describe '#.no_moves?' do
        it 'returns false if some move possible' do
            legal_moves = game.send(:construct_legal_moves, game.active_player)
            expect(game.send(:no_moves?, legal_moves)).to be false
        end

        it 'returns true if no moves are possible' do
            white_pawn1 = game.player1.find_piece([6,5])
            game.send(:move,white_pawn1,[5,5])
            black_pawn = game.player2.find_piece([1,4])
            game.send(:move,black_pawn, [3,4])
            white_pawn2 = game.player1.find_piece([6,6]) 
            game.send(:move,white_pawn2, [4,6])
            black_queen = game.player2.find_piece([0,3])
            game.send(:move, black_queen, [4,7])

            legal_moves = game.send(:construct_legal_moves,game.active_player)
            expect(game.send(:no_moves?, legal_moves)).to be true
            game.send(:unmove, black_queen)
            game.send(:unmove, white_pawn2)
            game.send(:unmove, black_pawn)
            game.send(:unmove, white_pawn1)
        end
    end
    
    describe '#.castle?' do
        king = game.active_player.find_pieces("King")
        queen_rook = game.active_player.find_piece([7,0])
        king_rook = game.active_player.find_piece([7,7])
        queen_knight = game.active_player.find_piece([7,1])
        king_knight = game.active_player.find_piece([7,6])
        queen_bishop = game.active_player.find_piece([7,2])
        king_bishop = game.active_player.find_piece([7,5])
        queen = game.active_player.find_piece([7,3])
        pawn = game.active_player.find_piece([6,5])
        opponent_pawn1 = game.inactive_player.find_piece([1,0])
        opponent_pawn2 = game.inactive_player.find_piece([1,1])
        opponent_rook = game.inactive_player.find_piece([0,7])
        it 'returns false if blocked' do
            game.send(:move, queen_knight, [5,1])
            game.send(:move, queen_bishop, [5,2])
            game.send(:move, king_knight, [5,7])
            expect(game.send(:castle?, king, queen_rook)).to be false
            expect(game.send(:castle?, king, king_rook)).to be false
        end

        it 'returns false if king passes through threatened square' do
            game.send(:move, king_bishop, [5,4])
            game.send(:move, pawn, [5,6])
            game.send(:move, queen, [5,3])
            game.send(:move, opponent_pawn1, [6,1])
            game.send(:move, opponent_rook, [2,5])
            expect(game.send(:castle?, king, queen_rook)).to be false
            expect(game.send(:castle?, king, king_rook)).to be false
        end

        it 'returns true if castle is legal' do
            game.send(:unmove, opponent_rook)
            game.send(:unmove, opponent_pawn1)
            expect(game.send(:castle?, king, queen_rook)).to be true
            expect(game.send(:castle?, king, king_rook)).to be true
            game.send(:unmove, queen)
            game.send(:unmove, pawn)
            game.send(:unmove, king_bishop)
            game.send(:unmove, king_knight)
            game.send(:unmove, queen_bishop)
            game.send(:unmove, queen_knight)
        end
        
    end

    describe '#.add_castles' do
        it 'adds no castle moves to king' do
            legal_moves = game.send(:construct_legal_moves, game.active_player)
            king_moves = legal_moves[game.active_player.find_pieces("King")]
            castles = [[7,2], [7,6]]
            castles.each do |castle|
                expect(king_moves.include?(castle)).to be false
            end
        end

        it 'adds queen side castle move' do
            king = game.active_player.find_pieces("King")
            queen_rook = game.active_player.find_piece([7,0])
            king_rook = game.active_player.find_piece([7,7])
            queen_knight = game.active_player.find_piece([7,1])
            king_knight = game.active_player.find_piece([7,6])
            queen_bishop = game.active_player.find_piece([7,2])
            king_bishop = game.active_player.find_piece([7,5])
            queen = game.active_player.find_piece([7,3])

            game.send(:move, queen_knight, [5,1])
            game.send(:move, queen_bishop, [5,2])
            game.send(:move, queen, [5,3])

            legal_moves = game.send(:construct_legal_moves, game.active_player)
            king_moves = legal_moves[game.active_player.find_pieces("King")]

            expect(king_moves.include?([7,2])).to be true
            expect(king_moves.include?([7,6])).to be false

            game.send(:unmove, queen)
            game.send(:unmove, queen_bishop)
            game.send(:unmove, queen_knight)
        end

        it 'adds king side castle move' do
            king = game.active_player.find_pieces("King")
            king_rook = game.active_player.find_piece([7,7])
            king_knight = game.active_player.find_piece([7,6])
            king_bishop = game.active_player.find_piece([7,5])
            
            game.send(:move, king_knight, [5,7])
            game.send(:move, king_bishop, [5,4])

            legal_moves = game.send(:construct_legal_moves, game.active_player)
            king_moves = legal_moves[game.active_player.find_pieces("King")]

            expect(king_moves.include?([7,2])).to be false
            expect(king_moves.include?([7,6])).to be true

            game.send(:unmove, king_bishop)
            game.send(:unmove, king_knight)
        end
    end

    describe '#.move' do
        white_pawn = game.active_player.find_pieces("Pawn")[0]
        black_pawn = game.inactive_player.find_pieces("Pawn")[0]

        it 'sets Pawn en passant to true when appropriate' do
            game.send(:move, white_pawn, [4,0])
            expect(white_pawn.en_passant).to be true
            game.send(:move, black_pawn, [3,0])
            expect(black_pawn.en_passant).to be true

        end

        it 'sets Pawn en passant to false when appropriate' do
            game.send(:unmove, black_pawn)
            game.send(:move, black_pawn, [2,0])
            expect(black_pawn.en_passant).to be false
            game.send(:move, white_pawn, [3,0])
            expect(white_pawn.en_passant).to be false
            game.send(:unmove, white_pawn)
            game.send(:unmove, black_pawn)
            game.send(:unmove, white_pawn)
        end

        it 'takes a piece when a pawn performs an en passant take' do
            game.send(:move, white_pawn, [3,1])
            game.send(:move, black_pawn, [3,0])
            game.send(:move, white_pawn, [2,0])
            
            expect(game.player2.taken.include?(black_pawn)).to be true
            game.send(:unmove, white_pawn)
            game.send(:unmove, black_pawn)
            game.send(:unmove, white_pawn)            
        end

        it 'handles castling' do
            king = game.active_player.find_pieces("King")
            queen_rook = game.active_player.find_piece([7,0])
            king_rook = game.active_player.find_piece([7,7])
            queen_knight = game.active_player.find_piece([7,1])
            king_knight = game.active_player.find_piece([7,6])
            queen_bishop = game.active_player.find_piece([7,2])
            king_bishop = game.active_player.find_piece([7,5])
            queen = game.active_player.find_piece([7,3])

            game.send(:move, queen_knight, [5,1])
            game.send(:move, queen_bishop, [5,2])
            game.send(:move, queen, [5,3])
            game.send(:move, king_knight, [5,7])
            game.send(:move, king_bishop, [5,4])

            game.send(:move, king, [7,2])
            #game.board.show
            expect(game.board.field[7][2]).to eql(king)
            expect(game.board.field[7][3]).to eql(queen_rook)

            game.send(:unmove, king)
            #game.board.show

            game.send(:move, king, [7,6])
            #game.board.show
            expect(game.board.field[7][6]).to eql(king)
            expect(game.board.field[7][5]).to eql(king_rook)

            game.send(:unmove, king)
            #game.board.show

            game.send(:unmove, king_bishop)
            game.send(:unmove, king_knight)
            game.send(:unmove, queen)
            game.send(:unmove, queen_bishop)
            game.send(:unmove, queen_knight)
        end
    end

    describe '#.add_en_passant' do
        it 'adds nothing when no en passant' do
            legal_moves = game.send(:construct_legal_moves, game.active_player)
            expected_moves = {
                game.active_player.find_piece([7,0]) => [],
                game.active_player.find_piece([7,7]) => [],
                game.active_player.find_piece([7,1]) => [[5,2], [5,0]],
                game.active_player.find_piece([7,6]) => [[5,7], [5,5]],
                game.active_player.find_piece([7,2]) => [],
                game.active_player.find_piece([7,5]) => [],
                game.active_player.find_piece([7,3]) => [],
                game.active_player.find_piece([7,4]) => [],
                game.active_player.find_piece([6,0]) => [[5,0], [4,0]],
                game.active_player.find_piece([6,1]) => [[5,1], [4,1]],
                game.active_player.find_piece([6,2]) => [[5,2], [4,2]],
                game.active_player.find_piece([6,3]) => [[5,3], [4,3]],
                game.active_player.find_piece([6,4]) => [[5,4], [4,4]],
                game.active_player.find_piece([6,5]) => [[5,5], [4,5]],
                game.active_player.find_piece([6,6]) => [[5,6], [4,6]],
                game.active_player.find_piece([6,7]) => [[5,7], [4,7]]
            }

            expected_moves.each do |piece, moves|
                expect(legal_moves[piece]).to eql(moves)
            end
        end

        it 'adds valid en passant takes' do
            black_pawn = game.player2.find_pieces('Pawn')[0]
            white_pawn = game.player1.find_pieces('Pawn')[0]

            game.send(:move, white_pawn, [3,1])
            game.send(:move, black_pawn, [3,0])
            legal_moves = game.send(:construct_legal_moves, game.active_player)
            expect(legal_moves[white_pawn].include?([2,0])).to be true

            game.send(:unmove, black_pawn)
            game.send(:unmove, white_pawn)

            game.send(:move, black_pawn, [4,1])
            game.send(:move, white_pawn, [4,0])
            legal_moves = game.send(:construct_legal_moves, game.inactive_player)
            expect(legal_moves[black_pawn].include?([5,0])).to be true
            game.send(:unmove, white_pawn)
            game.send(:unmove, black_pawn)
        end
    end

    describe '#.round' do
        it 'runs through a round assuming valid choices' do
            pawn = game.player1.find_piece([6,3])
            game.stub(:gets).and_return("d2\n", "d4\n")
            game.round
            #game.board.show
            expect(game.active_player).to eql(game.player2)
        end

        it 're-requests a piece if not picking your piece' do
            game.stub(:gets).and_return("c1\n", "e7\n", "e5\n")
            game.round
            #game.board.show
            expect(game.active_player).to eql(game.player1)
        end

        it 're-requests a move if the move is invalid' do
            game.stub(:gets).and_return("c1\n", "h4\n", "h6\n")
            game.round
            #game.board.show
            expect(game.active_player).to eql(game.player2)
        end
    end

    describe '#.save_quit?' do
        it 'returns true if given s or q' do
            inputs = ["S", "s", "Q", "q"]
            inputs.each do |input|
                expect(game.send(:save_quit?, input)).to be true
            end

        end

        it 'returns false otherwise' do
            expect(game.send(:save_quit?, "b3\n")).to be false
        end
    end

    describe '#.random_piece' do
        it 'selects a non empty piece' do
            legal_moves = game.send(:construct_legal_moves, game.active_player)
            piece = game.send(:random_piece, legal_moves)
            expect(legal_moves[piece].empty?).to be false
        end
    end

    describe '#.random_move' do
        it 'selects a move from the given pieces legal moves' do
            legal_moves = game.send(:construct_legal_moves, game.active_player)
            pawn = game.active_player.find_pieces("Pawn")[0]
            random_move = game.send(:random_move, legal_moves, pawn)
            valid_moves = legal_moves[pawn]
            expect(valid_moves.include?(random_move)).to be true
        end
    end
end