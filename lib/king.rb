require_relative "./jumper"
class King < Jumper

    attr_accessor :position #for testing

    def initialize(color)
        @sym = 'K'
        @position = color == 'black' ? [0,4] : [7,4]
    end
end