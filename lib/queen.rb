require_relative "./slider"
class Queen < Slider

    attr_accessor :position #for testing

    def initialize(color)
        @sym = 'Q'
        @position = color == 'black' ? [0,3] : [7,3]
    end
end