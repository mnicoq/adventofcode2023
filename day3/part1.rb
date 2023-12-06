INPUT_FILENAME = "input.txt"
#INPUT_FILENAME = "sample.txt"  # >> Test result: 4361 !

# Sample schematic
# 467..114..
# ...*......
# ..35..633.
# ......#...
# 617*......
# .....+.58.
# ..592.....
# ......755.
# ...$.*....
# .664.598..

class PartNumber

    attr_accessor :full_value
    attr_accessor :start_idx
    attr_accessor :end_idx
    attr_accessor :is_valid

    def initialize(intValue, start_idx, end_idx)
        self.full_value = intValue
        self.start_idx = start_idx
        self.end_idx = end_idx
        self.is_valid = false
    end

    # If a PartNumber collapses with a symbol, it is a valid part number.
    def is_collapsing?(symbol_idx)
        range = Range::new(start_idx-1,end_idx+1)
        self.is_valid = is_valid || range.include?(symbol_idx)
        return is_valid
    end
end


def main

    # Parse the input into two structures.
    # One has PartNumbers, ordered by line. Each PartNumber knows its start/end index.
    # So, for sample schematic: 
    # {
    #   1 => [ { full_value: 467, indexes: [0,2] }, { full_value: 114, indexes: [5,7] } ],
    #   3 => [ { full_value: 35, indexes: [2,3] }, { full_value: 633, indexes: [6,8] } ],
    #   ...
    # }  

    part_numbers = {}

    # Other has symbols with index, stored by line
    # So, for sample schematic:
    # {
    #   2 => [3],
    #   4 => [6],
    #   5 => [3],
    #   6 => [5],
    #   8 => [3, 5]
    # } 
    #
    symbols = {}

    # Read by chunks, not all file into memory
    File.foreach(INPUT_FILENAME).with_index do |line, line_num|
        # puts "#{line_num}: #{line}"
        partial_num = ""
        chars = line.split("")
        idx = 0
        while idx < chars.length && chars[idx] != "\n" do
            if (numeric?(chars[idx]))
                # puts "Its a number, starts on #{idx}"
                starting_idx = idx
                # Consume next chars to form a number
                while idx < chars.length && numeric?(chars[idx]) do
                    partial_num+=chars[idx]
                    idx += 1
                end
                # End at failure point, so get back one char for next round
                idx -= 1
                ending_index = idx
                number_to_store = PartNumber.new(partial_num.to_i, starting_idx,ending_index)
                if (part_numbers[line_num] == nil)
                    # New bucket
                    part_numbers[line_num] = [number_to_store]
                else
                    # Add to bucket
                    part_numbers[line_num] << number_to_store
                end
                # Clear for next number gen
                partial_num = ""
            elsif (chars[idx] != ".")
                # puts "Its a symbol"
                if (symbols[line_num] == nil)
                    # New bucket
                    symbols[line_num] = [idx]
                else
                    # Add to bucket
                    symbols[line_num] << (idx)
                end
            end

            idx += 1
        end
    end

    # Per symbol, do a check in: line-1, line and line+1
    # Where there is a number that has collapsing index, erase it
    # Do this for all symbols
    
    symbols.each do |line,indexes|
        #puts "Looking at line #{line} with symbols: #{indexes}"
        indexes.each do |symbol_idx| 
            #puts "Now goes sym_idx: #{symbol_idx}"
            for active_line in Range::new(line-1,line+1) do
                next if (part_numbers[active_line] == nil)
                part_numbers[active_line].each do |part_num| 
                    part_num.is_collapsing?(symbol_idx)
                    # if (part_num.is_collapsing?(symbol_idx))
                    #     puts "#{part_num.full_value} on line #{active_line} marked"
                    #    # part_numbers[active_line].delete(part_num)
                    # end
                end
            end 
        end
    end

    # The resulting numbers who are valid are to be summed up
    total_sum = 0
    part_numbers.each do |line,numbers| 
        total_sum += numbers.map { |n| n.is_valid ? n.full_value : 0 }.sum # Full values partial line sum
    end

   return total_sum
end

# RegExp matchers to see if a character is a digit
def numeric?(lookAhead)
    lookAhead.match?(/[[:digit:]]/)
end

# Testing 
# puts PartNumber.new(124, 2, 4).is_collapsing?(3)  # Yep it's under
# puts PartNumber.new(12, 3, 4).is_collapsing?(3)   # Yep it's on the left
# puts PartNumber.new(124, 4, 6).is_collapsing?(3)  # Yep it's diagonal left
# puts PartNumber.new(124, 5, 7).is_collapsing?(3)  # No touching

puts main