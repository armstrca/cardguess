require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "http"
require "json"
require "dotenv"
require "sinatra/cookies"
require "better_errors"

$card_values = ["A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"]
$suits_all = ["♣︎", "♠︎", "♥︎", "♦︎"]

@deck_hash = {}
  
# trying to write something that makes the correct cards go to the correct piles. So pile 1 should follow the pattern of 1, 5, 9, 13, 17; pile 2 would be 2, 6, 10, 14, 18; etc..
=begin
def pile2 
  $dealer_deck
  $dealer_deck_index += 1
  $deal = $dealer_deck[$dealer_deck_index.step(2..4)]
end
=end


$suits_all.each do |suit|
  @deck_hash[suit] = $card_values.map { |value| "#{suit}#{value}"}
end

$clubs_array = @deck_hash["♣︎"] 
$spades_array = @deck_hash["♠︎"] 
$hearts_array = @deck_hash["♥︎"] 
$diamonds_array = @deck_hash["♦︎"] 
@deck_array = []
@deck_array.concat($clubs_array, $spades_array, $hearts_array, $diamonds_array)
@deck_array.push("Joker", "Joker")
@dealer_deck = @deck_array.sample

Num = 24
#Num = rand 69..420
$dealer_deck = []

(Num.to_i).times do
  $dealer_deck = $dealer_deck.push(@deck_array.sample)
end

############################################################################


def distribute_to_piles(deck)
  piles = Array.new(4) { [] }

  deck.each_with_index do |card, index|
    pile_index = index % 4
    piles[pile_index] << card
  end

  piles
end
public


$dealer_deck
@piles = distribute_to_piles($dealer_deck)

# code that loops through each individual array in @piles 1 by 1,
# only displaying/dealing the card most recently dealt in each pile
def full_pile_deal(piles, current_card_indices)
  result = ""
  piles.each_with_index do |pile, pile_index|
    current_card_index = current_card_indices[pile_index]
    current_card = pile[current_card_index]

    result += "Pile #{pile_index + 1}: #{current_card}<br>"

    current_card_indices[pile_index] = (current_card_index + 1) % pile.length
    current_card.delete
  end
  result
end


piles = [@piles[0], @piles[1], @piles[2], @piles[3]]  # Your array of piles
current_card_indices = [-1, -1, -1, -1]  # Initialize the current card index for each pile

# Call the function to display the next card from each pile
full_pile_deal(piles, current_card_indices)


"9999999999999999999999999999999999999999999999999999999999999" 
#pp @piles.full_pile_deal(@piles[0])
#@piles.full_pile_deal(@piles[1])
#@piles.full_pile_deal(@piles[2])
#@piles.full_pile_deal(@piles[3])

##################################################################################
get("/") do
  $dealer_deck_index = 0
  $deal = $dealer_deck[$dealer_deck_index]
  $dealer_deck_index += 1
  $dealer_deck
  @piles = distribute_to_piles($dealer_deck)
  @current_card_indices = current_card_indices
  erb(:home)
end


get("/next_card") do
  $dealer_deck_index = 0
  $deal = $dealer_deck[$dealer_deck_index]
  $dealer_deck_index += 1
  $dealer_deck
  @piles = distribute_to_piles($dealer_deck)
  @current_card_indices = current_card_indices
  erb(:next_card)
end

get("/third_pile") do
  @dealer_deck_index = 0
  @deal = @dealer_deck[@dealer_deck_index]
  @dealer_deck_index += 1
  @piles = distribute_to_piles(@dealer_deck)
  @current_card_indices = current_card_indices
  erb(:third_pile)
end

get("/fourth_pile") do
  @dealer_deck_index = 0
  @deal = @dealer_deck[@dealer_deck_index]
  @dealer_deck_index += 1
  @piles = distribute_to_piles(@dealer_deck)
  @current_card_indices = current_card_indices
  erb(:fourth_pile)
end


def delete_last_card
  @piles.each_with_index do |card, index|


###########################################################
#Okay so now I need to work on only showing one pile at a time, and removing each dealt card from its corresponding array, so that eventually the deck will run out.
