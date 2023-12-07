
INPUT_FILENAME = "input.txt"
#INPUT_FILENAME = "sample.txt"

def main

    card_set = {}
    quantities = {}

    File.foreach(INPUT_FILENAME).with_index do |line, line_num|
        # Convert the line into a usable hash
        # Ignore the first part to the left of :
        line = line.split(':')[1]
        all_cards = line.split("|")
        # Initialize the strucs
        card_set[line_num+1] = all_cards 
        quantities[line_num+1] = 1 
       # puts card_set
       # puts quantities
    end

    card_set.each do |card_num, cards|
        winning_nums = cards[0].split(" ")
        numbers = cards[1].split(" ")
        
        num_clashing = winning_nums & numbers
        card_value = num_clashing.count
        next if card_value < 1
        # Apply a "modifier" to the next X cards based on value obtained
        modifier = quantities[card_num]
        for idx_num in Range::new(card_num+1, card_num+card_value) do
            quantities[idx_num] += 1 * modifier
        end
    end
    
    return quantities.values.sum
end

puts main