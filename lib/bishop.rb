require_relative "./slider"
class Bishop < Slider
    
    attr_accessor :position #for testing

    def initialize(color)
        super()
        @sym = color == 'black' ? "\u2657" : "\u265D"
        if @@count[self.class.to_s] == 1
            @position = color == 'black' ? [0, 2] : [7, 2]
        else
            @position = color == 'black' ? [0, 5] : [7, 5]
        end
    end
end