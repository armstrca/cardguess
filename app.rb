require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "http"
require "json"
require "dotenv"
require "sinatra/cookies"
require "better_errors"
enable :sessions

OPENAI_API_KEY = ENV.fetch("OPENAI_API_KEY")


$card_values = ["A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"]
$suits_all = ["♣︎", "♠︎", "♥︎", "♦︎"]

@deck_hash = {}


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
$dealer_deck = $deck_array.sample

Num = rand 30..223
$dealer_deck = []

(Num.to_i).times do
  $dealer_deck = $dealer_deck.push($deck_array.sample)
end
$dealer_deck.length

$dealer_deck = $dealer_deck.concat($deck_array)
$dealer_deck.length
def distribute_to_piles(deck)
  piles = Array.new(4) { [] }

  deck.each_with_index do |card, index|
    pile_index = index % 4
    piles[pile_index] << card
  end
  piles
end

@piles = distribute_to_piles($dealer_deck.shuffle!)

@pile1 = @piles[0] 
@pile2 = @piles[1]
@pile3 = @piles[2]
@pile4 = @piles[3]
current_card_indices = [-1, -1, -1, -1] 

pp @pile1.length
pp @pile2.length
pp @pile3.length
pp @pile4.length

get("/") do
  session[:cookiepile] ||= []
  erb(:home)
end


$current_step_index = 0

post("/next_card") do
  session[:cookiepile] ||= []
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
    pp session[:cookiepile] += [@pile1.first]
  when 1
    @pile2.shift if @pile2.length > 1
    pp session[:cookiepile] += [@pile2.first]
  when 2
    @pile3.shift if @pile3.length > 1
    pp session[:cookiepile] += [@pile3.first]
  when 3
    @pile4.shift if @pile4.length > 1
    pp session[:cookiepile] += [@pile4.first]
  end

  # Increment the index for the next step
  $current_step_index += 1
  $current_step_index %= 4
  # Store the updated @piles array back into the session
  session[:piles] = @piles
  session[:cookiepile]
  erb(:next_card)
end

post("/first_pile") do
  session[:cookiepile] ||= []
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
  pp session[:cookiepile] += [@pile1.first]
  @pile1
  erb(:first_pile)
end

post("/second_pile") do
  session[:cookiepile] ||= []
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
  pp session[:cookiepile] += [@pile2.first]
  @pile2
  erb(:second_pile)
end

post("/third_pile") do
  session[:cookiepile] ||= []
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
  pp session[:cookiepile] += [@pile3.first]
  @pile3
  erb(:third_pile)
end

post("/fourth_pile") do
  session[:cookiepile] ||= []
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

  pp session[:cookiepile] += [@pile4.first]
  @pile4
  erb(:fourth_pile)
end

get("/new_deck") do
  $card_values = ["A", 2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K"]
  $suits_all = ["♣︎", "♠︎", "♥︎", "♦︎"]

  @deck_hash = {}


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
  $dealer_deck = $deck_array.sample

  Num = rand 30..223
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

  @piles = distribute_to_piles($dealer_deck.shuffle!)
  session[:cookiepile1] ||= []
  session[:cookiepile2] ||= []
  session[:cookiepile3] ||= []
  session[:cookiepile4] ||= []
  redirect to ("/")
  erb(:home)
end

post("/chat") do
    
  pp  @chat_history = JSON.parse(cookies[:chat_history] || "[]")

  pp  @current_message = params.fetch("user_chat_msg")

  pp  @chat_history << { "role" => "user", "content" => @current_message }

  pp  request_headers_hash = {
      "Authorization" => "Bearer #{ENV.fetch("OPENAI_API_KEY")}",
      "content-type" => "application/json"
    }

  pp request_messages = [
      {
        "role" => "system",
        "content" => "You are a helpful assistant."
      },
      {
        "role" => "user",
        "content" => @current_message
      }
    ]

  @chat_history.each do |message|
      request_messages << {
        "role" => message["role"],
        "content" => message["content"]
      }
    end

  pp  request_body_hash = {
      "model" => "gpt-3.5-turbo",
      "messages" => request_messages
    }

    request_body_json = JSON.generate(request_body_hash)

    raw_response = HTTP.headers(request_headers_hash).post(
      "https://api.openai.com/v1/chat/completions",
      :body => request_body_json
    ).to_s

    @parsed_response = JSON.parse(raw_response)

    @reply = @parsed_response.dig("choices", 0, "message", "content")

    @chat_history << { "role" => "assistant", "content" => @reply }

    cookies[:chat_history] = JSON.generate(@chat_history)
    erb(:chat)
end
