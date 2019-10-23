require_relative "../lib/main"


describe '#.get_continue' do
    before do
        allow($stdout).to receive(:write)
    end
    it 'returns response if valid' do
        self.stub(:gets).and_return("Y", "y", "N", "n")
        ["Y", "y", "N", "n"].each do |response|
            expect(get_continue).to eql(response)
        end
    end

    it 're-prompts when given invalid input' do
        self.stub(:gets).and_return("Yes", "Y")
        expect(get_continue).to eql("Y")
    end
end

describe '#.yes?' do
    it 'return true if given "Y" or "y"' do
        expect(yes?("Y")).to be true
        expect(yes?("y")).to be true
    end

    it 'returns false if given "N" or "n"' do
        expect(yes?("N")).to be false
        expect(yes?("n")).to be false
    end
end

describe '#.save_game' do
    before do
        allow($stdout).to receive(:write)
    end
    it 'creates a save file named "save.txt' do
        game = Game.new
        save_game(game)
        expect(File.exist?('save.txt')).to be true
        File.delete('save.txt')
    end
end

describe '#.load_game' do
    before do
        allow($stdout).to receive(:write)
    end
    it 'loads a game from save.txt and deletes file' do
        game = Game.new
        save_game(game)
        loaded = load_game
        expect(loaded.is_a?(Game)).to be true
        expect(File.exist?('save.txt')).to be false
    end
end
