INPUT_FILENAME = "input.txt"
#INPUT_FILENAME = "sample.txt"  # >> Test result: 467835 !

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

    # If a PartNumber collapses with any symbol, it is a valid part number.
    def is_collapsing?(symbol_idx)
        range = Range::new(start_idx-1,end_idx+1)
        self.is_valid = is_valid || range.include?(symbol_idx)
        return is_valid
    end

    # If a PartNumber collapses with a particular symbol index.
    def is_single_collapsing?(symbol_idx)
        range = Range::new(start_idx-1,end_idx+1)
        return range.include?(symbol_idx)
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

    # Other has gears with index, stored by line
    # So, for sample schematic:
    # {
    #   2 => [3],
    #   7 => [5]
    # } 
    #
    gears = {}

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
            elsif (chars[idx] == "*")
                #puts "Got a gear symbol"
                if (gears[line_num] == nil)
                    # New bucket
                    gears[line_num] = [idx]
                else
                    # Add to bucket
                    gears[line_num] << (idx)
                end
            end

            idx += 1
        end
    end

    # Per gear do a check in: line-1, line and line+1
    # Where there is a number that has collapsing index, get a +1
    # If it has exactly two collapsing numbers, get the gear ratio
    # Gear ratio = multiply the part_numbers 
    # Do this for all gears
    total_sum = 0
    # puts "Here we go gears"
    # puts gears
    gears.each do |line,indexes|
        #puts "Looking at line #{line} with gears: #{indexes}"
        indexes.each do |symbol_idx| 
            impacts = 0
            gear_ratio = 1
            # puts "Now goes gear with idx: #{symbol_idx}"
            for active_line in Range::new(line-1,line+1) do
                next if (part_numbers[active_line] == nil)
                # puts "Now checking numbers at line #{active_line}"
                part_numbers[active_line].each do |part_num| 
                    if(part_num.is_single_collapsing?(symbol_idx))
                        impacts += 1
                        gear_ratio = gear_ratio * part_num.full_value
                        # puts "#{part_num.full_value} is particularly collapsing with a gear in #{symbol_idx}"
                    end
                end
            end 

            if (impacts == 2)
                #puts "Twas a proper gear. Ratio to add: #{gear_ratio}"
                total_sum += gear_ratio
            end
        end
    end

   return total_sum
end

# RegExp matchers to see if a character is a digit
def numeric?(lookAhead)
    lookAhead.match?(/[[:digit:]]/)
end

puts main