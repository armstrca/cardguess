require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "http"
require "json"
require "dotenv"
require "sinatra/cookies"
require "better_errors"

card_values = ["A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"]
suits_all = ["♣︎", "♠︎", "♥︎", "♦︎"]




get("/") do
  card_values = ["A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"]
  suits_all = ["♣︎", "♠︎", "♥︎", "♦︎"]
  @deck_hash = {}
  
  suits_all.each do |suit|
    @deck_hash[suit] = card_values.map { |value| "#{suit}#{value}"}
  end

  @deck_hash

  @clubs_array = @deck_hash["♣︎"] 
  @spades_array = @deck_hash["♠︎"] 
  @hearts_array = @deck_hash["♥︎"] 
  @diamonds_array = @deck_hash["♦︎"] 
  @deck_array = []
  @deck_array.concat(@clubs_array, @spades_array, @hearts_array, @diamonds_array)
  @deck_array.push("🃏", "🃏")
  @dealer_deck = @deck_array.sample
  

  Num = rand 69..420
  @dealer_deck = []

  (Num.to_i).times do
    @dealer_deck = @dealer_deck.push(@deck_array.sample)
  end


@dealer_deck_index = 0
@deal = @dealer_deck[@dealer_deck_index]
@dealer_deck_index += 1


erb(:home)
end

post("/next_card") do
  @dealer_deck_index += 1
  @deal = @dealer_deck[@card_index]
  @current_card
  erb(:next_card)
end
