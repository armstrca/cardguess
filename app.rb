require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "http"
require "json"
require "dotenv"
require "sinatra/cookies"
require "better_errors"
enable :sessions

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
$deck_array = []
$deck_array.concat($clubs_array, $spades_array, $hearts_array, $diamonds_array)
$deck_array.push("Joker", "Joker")
@dealer_deck = $deck_array.sample

Num = 13
#Num = rand 15..405
$dealer_deck = []

(Num.to_i).times do
  $dealer_deck = $dealer_deck.push($deck_array.sample)
end
pp $dealer_deck.length

$dealer_deck = $dealer_deck.concat($deck_array)
pp $dealer_deck.length
def distribute_to_piles(deck)
  piles = Array.new(4) { [] }

  deck.each_with_index do |card, index|
    pile_index = index % 4
    piles[pile_index] << card
  end
  piles
end

@piles = distribute_to_piles($dealer_deck)

# code that loops through each individual array in @piles 1 by 1,
# only displaying/dealing the card most recently dealt in each pile
# def full_pile_deal(piles, current_card_indices)
#   result = ""
#   piles.each_with_index do |pile, pile_index|
#       current_card_index = current_card_indices[pile_index]
#       current_card = pile[current_card_index]
#       result += "Pile #{pile_index + 1}: #{current_card}<br>"

#       current_card_indices[pile_index] = (current_card_index + 1) % pile.length
#   end
#   result
# end

@pile1 = @piles[0] 
@pile2 = @piles[1]
@pile3 = @piles[2]
@pile4 = @piles[3]

# def proper_dealing_order
#   @pile1 = @piles[0] 
#   @pile2 = @piles[1]
#   @pile3 = @piles[2]
#   @pile4 = @piles[3]
#   while !@pile1.empty? || !@pile4.empty?
#   if @pile1.length == @pile4.length
#     @pile1.shift
#     pp @piles
#   end
#   if @pile2.length > @pile1.length
#     @pile2.shift
#     pp @piles
#   end
#   if @pile3.length > @pile2.length
#     @pile3.shift
#     pp @piles
#   end
#   if @pile4.length > @pile3.length
#     @pile4.shift
#     pp @piles
#   end
#   # if @pile1.length.nil? && @pile4.length.nil?
#   #   puts "Game over!"
#   end
#   puts "Game over!"
# end

piles = [@piles[0], @piles[1], @piles[2], @piles[3]]  # Your array of piles
current_card_indices = [-1, -1, -1, -1]  # Initialize the current card index for each pile

# Call the function to display the next card from each pile
# full_pile_deal(piles, current_card_indices)


"9999999999999999999999999999999999999999999999999999999999999" 
pp @pile1.length
pp @pile2.length
pp @pile3.length
pp @pile4.length

get("/") do
  erb(:home)
end

$current_step_index = 0

get("/next_card") do
  $current_step_index += 0
  $dealer_deck_index = 0
  $deal = $dealer_deck[$dealer_deck_index]
  $dealer_deck_index += 0
  $dealer_deck
  @piles = session[:piles] || distribute_to_piles($dealer_deck)
  @current_card_indices = current_card_indices
  @pile1 = @piles[0]
  @pile2 = @piles[1]
  @pile3 = @piles[2]
  @pile4 = @piles[3]
  case $current_step_index
  when 0
    @pile1.shift if @pile1.length > 1
  when 1
    @pile2.shift if @pile2.length > 1
  when 2
    @pile3.shift if @pile3.length > 1
  when 3
    @pile4.shift if @pile4.length > 1
  end

  # Increment the index for the next step
  $current_step_index += 1
  $current_step_index %= 4
  # Store the updated @piles array back into the session
  session[:piles] = @piles

  erb(:next_card)
end

get("/first_pile") do
  $current_step_index += 0
  $dealer_deck
  @piles = session[:piles] || distribute_to_piles($dealer_deck)
  @current_card_indices = current_card_indices
  @pile1 = @piles[0]
  @pile2 = @piles[1]
  @pile3 = @piles[2]
  @pile4 = @piles[3]

  # Increment the index for the next step
  $current_step_index += 1
  $current_step_index %= 4
  # Store the updated @piles array back into the session
  session[:piles] = @piles
  pp @pile1
  erb(:first_pile)
end

get("/second_pile") do
  $dealer_deck
  @piles = session[:piles] || distribute_to_piles($dealer_deck)
  @current_card_indices = current_card_indices
  @pile1 = @piles[0]
  @pile2 = @piles[1]
  @pile3 = @piles[2]
  @pile4 = @piles[3]

  # Increment the index for the next step
  $current_step_index += 1
  $current_step_index %= 4
  # Store the updated @piles array back into the session
  session[:piles] = @piles
  pp @pile2
  erb(:second_pile)
end

get("/third_pile") do
  $dealer_deck
  @piles = session[:piles] || distribute_to_piles($dealer_deck)
  @current_card_indices = current_card_indices
  @pile1 = @piles[0]
  @pile2 = @piles[1]
  @pile3 = @piles[2]
  @pile4 = @piles[3]

  # Increment the index for the next step
  $current_step_index += 1
  $current_step_index %= 4
  # Store the updated @piles array back into the session
  session[:piles] = @piles
  pp @pile3
  erb(:third_pile)
end

get("/fourth_pile") do
  $dealer_deck
  @piles = session[:piles] || distribute_to_piles($dealer_deck)
  @current_card_indices = current_card_indices
  @pile1 = @piles[0]
  @pile2 = @piles[1]
  @pile3 = @piles[2]
  @pile4 = @piles[3]

  # Increment the index for the next step
  $current_step_index += 1
  $current_step_index %= 4
  # Store the updated @piles array back into the session
  session[:piles] = @piles
  pp @pile4
  erb(:fourth_pile)
end

get("/new_deck") do
  (Num.to_i).times do
    $dealer_deck = $dealer_deck.push($deck_array.sample)
  end

  $dealer_deck = $dealer_deck.concat($deck_array)

  @piles = distribute_to_piles($dealer_deck)
  @pile1 = @piles[0] 
  @pile2 = @piles[1]
  @pile3 = @piles[2]
  @pile4 = @piles[3]
  
  redirect to ("/")
  erb(:home)
end
