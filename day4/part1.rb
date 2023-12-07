
INPUT_FILENAME = "input.txt"
# INPUT_FILENAME = "sample.txt"

def main

    sum = 0
    File.foreach(INPUT_FILENAME).with_index do |line, line_num|
        # Convert the line into a usable hash
        # Ignore the first part to the left of :
        line = line.split(':')[1]
        cards = line.split("|")
        winning_nums = cards[0].split(" ")
        numbers = cards[1].split(" ")

        num_clashing = winning_nums & numbers
        card_value = get_card_value(num_clashing.count)
        puts "Card Value at #{line_num+1}: #{card_value}"
        sum += card_value
    end
    sum
end

def get_card_value(number)
    return 0 if number < 1
    return 2 ** (number-1)
end

puts main