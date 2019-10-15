require_relative "./slider"
class Queen < Slider

    attr_accessor :position #for testing

    def initialize(color)
        super(color)
        @sym = color == 'black' ?  "\u2655" : "\u265B"
        @position = color == 'black' ? [0,3] : [7,3]
    end
end