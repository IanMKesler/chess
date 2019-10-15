require_relative "./jumper"
class Knight < Jumper

    attr_accessor :position #for testing

    def initialize(color)
        super(color)
        @sym = color == 'black' ? "\u2658" : "\u265E"
        count = @@count[self.class.to_s]
        if count == 1
            @position = color == 'black' ? [0, 1] : [7, 1]
        else
            @position = color == 'black' ? [0, 6] : [7, 6]
        end
    end
end