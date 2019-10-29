require_relative "./jumper"
class King < Jumper

    attr_accessor :position #for testing

    def initialize(color)
        super(color)
        @sym = color == 'black' ? "\u2654" : "\u265A"
        @position = color == 'black' ? [0,4] : [7,4]
    end
end