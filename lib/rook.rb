require_relative "./slider"
class Rook < Slider    

    attr_accessor :position #for testing

    def initialize(color)
        super()
        @sym = 'R'
        case @@count[self.class.to_s]
        when 1
            @position = color == 'black' ? [0,0] : [7,0]
        when 2
            @position = color == 'black' ? [0,7] : [7,7]
        end
    end
end