class Board

    attr_accessor :field
    attr_reader :column_reference

    def initialize
        @column_reference = {
            0 => 'a', 1 => 'b', 2 => 'c', 3 => 'd', 4 => 'e',
            5 => 'f', 6 => 'g', 7 => 'h'
        }
        @field = []
        8.times do 
            row = []
            8.times do
                row << nil
            end
            @field << row
        end
    end

    def show
        spacer
        column_letters
        @field.each_with_index do |row, r_index|
            divider
            row.each_with_index do |piece, c_index|
                row_number(r_index) if c_index == 0
                visual = piece ? piece.sym : ' '
                print "| #{visual} "
            end
            print "|"
            row_number(r_index)
            print "\n"
        end
        divider
        column_letters
        spacer
    end

    private

    def row_number(row)
        print " #{(8-row)} "
    end

    def column_letters
        print "   "
        8.times do |i|
            print "  #{@column_reference[i]} "
        end
        print "\n"
    end

    def spacer
        puts
    end

    def divider
        print "   "
        8.times do
            print "----"
        end
        print "-\n"
    end
end