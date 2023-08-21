require "sinatra"
require 'sinatra/contrib'
require "sinatra/reloader"
require "sinatra/activerecord"
require "http"
require "json"
require "dotenv"
require "sinatra/cookies"
require "better_errors"
require 'rack/session/cookie'
enable :sessions

use Rack::Session::Cookie, secret: '12345'

OPENAI_API_KEY = ENV.fetch("OPENAI_API_KEY")

#Setting up the cards...
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

  Num = rand 30..113
  $dealer_deck = []

  (Num.to_i).times do
    $dealer_deck = $dealer_deck.push($deck_array.sample)
  end

  $dealer_deck = $dealer_deck.concat($deck_array)
  pp "There are #{$dealer_deck.length} cards in the deck."

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

  @pile1.length
  @pile2.length
  @pile3.length
  @pile4.length


  get("/") do
  erb(:home)
end

$characters = {
  a: "Uruk-hai from Middle-Earth",
  b: "Guy who bases all his decisions off what Jesus would do",
  c: "Brusque 1950s diner waitress",
  d: "Flirty baron who loves poaching",
  e: "Elvis Presley",
  f: "Pirate queen with a heart of gold",
  g: "Amnesiac medieval knight who was asleep for centuries and woke back up in the Old West",
  h: "Cthulhu",
  i: "Micolash, Host of the Nightmare from the game Bloodborne",
  j: "Alexander Pushkin with a bad headache",
  k: "Paul F. Tompkins",
  l: "A robot that loves dancing but is forever chained to the track it's installed on",
  m: "A dog",
  n: "An obnoxious conspiracy theorist",
  o: "The creator of TimeCube",
  p: "A disappointed but loving dad"
}

$current_step_index = 0



post("/new_deck") do
  session[:cookiepile1] = []
  session[:cookiepile2] = []
  session[:cookiepile3] = []
  session[:cookiepile4] = []
  session[:current_step_index_cookie] = []
  $current_step_index = 0
  session[:current_step_index_cookie] << $current_step_index
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

  Num = rand 30..113
  $dealer_deck = []

  (Num.to_i).times do
    $dealer_deck = $dealer_deck.push($deck_array.sample)
  end

  $dealer_deck = $dealer_deck.concat($deck_array)
  pp "There are #{$dealer_deck.length} cards in the deck."

  def distribute_to_piles(deck)
    piles = Array.new(4) { [] }

    deck.each_with_index do |card, index|
      pile_index = index % 4
      piles[pile_index] << card
    end
    piles
  end

  session[:piles] = distribute_to_piles($dealer_deck.shuffle!)
  @piles = session[:piles]
  @pile1 = @piles[0] 
  @pile2 = @piles[1]
  @pile3 = @piles[2]
  @pile4 = @piles[3]
  current_card_indices = [-1, -1, -1, -1] 
  redirect to ("/")
  erb(:home)
end

post("/next_card") do
  $chatgpt_instructions = 
    "We are going to play a game called Card Guess.

    Here are the rules:

    1. There is one dealer, and 5 players. You are not the dealer. You are each of the 5 players. DO NOT NARRATE THE GAME AS A DEALER. DO NOT SPEAK AS IF YOU ARE A GAME SHOW HOST. ONLY INTERACT WITH THE GAME AS A PLAYER WITH WHATEVER PERSONALITY IS ASSIGNED TO THAT PLAYER.

    2. The game is played with standard playing cards - an indeterminate amount greater than one deck (52 cards plus two jokers) but smaller than 4 total decks. This way card counting is not really possible. The list of all possible valid cards is represented by this array: #{$deck_array}.

    3. Players take turns guessing what the next card dealt will be, based on the 'player styles/personalities' I will list for you later. When the game is initiated, chatGPT will assign each of its players one of the player styles/personalities from that list, and each player will maintain that player style/personality for the entirety of the game.

    4. After each guess, the dealer places the next card down. The first four cards dealt are placed side by side from left to right. Every card after that is placed on top of a previous card, so card 5 would be on top of card 1, card 8 on top of card 4, etc.. The first card pile is #{session[:cookiepile1]}, the second card pile is #{session[:cookiepile2]}, the third card pile is #{session[:cookiepile3]}, and the fourth card pile is #{session[:cookiepile3]}. Each player is trying to correctly guess what the next string added to their corresponding pile array will be. Because there are 4 piles and 5 players, each player will be guessing the next card for a different pile each turn (i.e., Player 1's first turn will be for pile 1, their second turn will be for pile 2, Player 5's first turn will be for pile 1, Player 3's second turn will be for pile 4, Player 3's third turn will be for pile 1, etc.). ChatGPT will keep track of which player's turn it is by using this array: #{session[:current_step_index_cookie]}, using the following pattern:
    Player 1's first turn will correspond with the first 0 in the array and every 5th array value afterward (i.e.: array values 0, 5, 10, 15, 20, etc.)
    Player 2's first turn will correspond with the first 1 in the array and every 5th number afterward. (i.e.: array values 1, 6, 11, 16, 21, etc.)
    Player 3's first turn will correspond with the first 2 in the array and every 5th number afterward. (i.e.: array values 2, 7, 12, 17, 22, etc.)
    Player 4's first turn will correspond with the first 3 in the array and every 5th number afterward. (i.e.: array values 3, 8, 13, 18, 23, etc.)
    Player 5's first turn will correspond with the second 0 in the array and every 5th number afterward. (i.e.: array values 4, 9, 14, 19, 24, etc.)

    5. Players can only win a point by correctly guessing both the suit and number of a card. The game continues until the dealer runs out of cards. Players' guesses have to precisely match the newest string appended to the relevant 'session[:cookiepile_]'' array in order to earn a point. If a player guesses a card correctly, they win a point. If a player guesses a Joker card correctly, they win three points, BUT if they guess a Joker card *incorrectly* they will lose 2 points. Incorrect guesses of non-Joker cards will not be penalized. The player with the most points when the dealer runs out of cards is the winner.

    6. If the card dealt is a Joker but the player did not guess 'Joker', that player must forget what another player three deals ago guessed, and then try to guess what *their* guess was. If the player guesses their guess correctly, that player will earn 1 point.

    7. At the beginning of each POST action invoking chatGPT, chatGPT will generate a 'card guess' from one of the five 'players' it represents BEFORE the card is revealed. The 'card guess' will consist of two parts: the first part, named @player_guess, is a single string value from '$deck_array': #{$deck_array}. The second part is that 'player character's' 'reasoning' for their guess, which will be called @player_reasoning. AFTER the next card has been revealed, that player will respond to the result. If the result did not score the player a point, their response will be no longer than one sentence long. If it did score the player a response, their response can be any length.

    8. This game in and of itself is not automatically fun. Thus, participants are expected to improvise and provide reasoning, serious/fatuous/silly/heartbreaking or otherwise, for why they are not 'guessing' but in fact are quite certain of what the next card will be.

    9. Each of the players may choose to take what other players have said and guessed into account. They may also take into account the contents of #{session[:cookiepile1]}, #{session[:cookiepile2]}, #{session[:cookiepile3]}, and #{session[:cookiepile1]} when making guesses and providing reasoning for them. But this is not mandatory.

    10. DO NOT DESCRIBE HOW THE GAME WORKS. DO NOT DESCRIBE ASSIGNING PERSONALITIES TO THE PLAYERS. THE PLAYER'S PERSONALITY SHOULD ONLY BE APPARENT THROUGH THEIR BEHAVIOR, NOT THROUGH EXPLICIT THIRD-PERSON OR SECOND-PERSON DESCRIPTIONS OF THEM. DO NOT LABEL THE PLAYER IN ANY WAY OTHER THAN PLAYER 1, 2, 3, 4, OR 5. DO NOT EVER TYPE OUT THE TEXT OF THEIR PERSONALITY TYPE. THEIR PERSONALITY AND IDENTITY SHOULD BE REVEALED IMPLICITLY RATHER THAN EXPLICITLY. NEVER PUT THEIR PERSONALITY TITLE IN ANY OF THE MESSAGES YOU SEND.

    11. You must format/structure all of your responses as follows:
        You must first send one separate message in the format of a hash: { player => player_guess }, where player represents whichever of the 5 players is currently guessing, and player_guess is a value taken from the '$deck_array' specified above in Rule 7.
        You must then send another separate message, again in the format of a hash: { player => player_reasoning }, where player still represents whichever of the 5 players is currently guessing, and player_reasoning is a string in which the player may choose to explain their guess or not, depending on their personality, and following the other rules and guidelines set out in these rules/instructions. Do not alter the titles of any of these keys at all.
        Once the player has submitted a guess and a card has been dealt, you must send a third message, again in the format of a hash: { player => deal_response }, where player still represents whichever of the 5 players just guessed, and deal_response is a narrative string in which the player character responds to the result. Do not alter the titles of any of these keys at all.

    12. Here is the list of player styles/personalities: #{$characters.to_a.shuffle.to_h} Shuffle the list and choose one at random for each of the 5 players, and ensure that no two players share the same one."


  # ideal_format
    begin
      @game_history = JSON.parse(cookies[:game_history] || JSON.generate([]))
    rescue JSON::ParserError => e
      # Handle the parsing error, for example, you could set an empty game history
      @game_history = []
      # You might want to log the error for debugging purposes
      puts "Error parsing game history JSON: #{e.message}"
    end
    
    $state_of_play = [session[:cookiepile1], session[:cookiepile2], session[:cookiepile3], session[:cookiepile4], session[:current_step_index_cookie], cookies[:game_history]].to_s

    @game_history << { "role" => "user", "content" => $state_of_play.to_s }

    request_headers_hash = {
        "Authorization" => "Bearer #{ENV.fetch("OPENAI_API_KEY")}",
        "content-type" => "application/json"
      }

    request_messages = [
      {
        "role" => "system",
        "content" => $characters.to_a.shuffle.to_s
      },
      {
        "role" => "system",
        "content" => "$state_of_play = [session[:cookiepile1], session[:cookiepile2], session[:cookiepile3], session[:cookiepile4], session[:current_step_index_cookie], cookies[:game_history]]. Here is $state_of_play: #{$state_of_play}"
      },

        {
          "role" => "system",
          "content" => $chatgpt_instructions
        },
        {
          "role" => "user",
          "content" => "$state_of_play = [session[:cookiepile1], session[:cookiepile2], session[:cookiepile3], session[:cookiepile4], session[:current_step_index_cookie], cookies[:game_history]]. Here is $state_of_play: #{$state_of_play}"
        }
      ]

    # @game_history.each do |message|
    #     request_messages << {
    #       "role" => message["role"],
    #       "content" => message["content"]
    #     }
    #   end

      request_body_hash = {
        "model" => "gpt-3.5-turbo-16k-0613",
        "messages" => request_messages
      }

      request_body_json = JSON.generate(request_body_hash)

      raw_response = HTTP.headers(request_headers_hash).post(
        "https://api.openai.com/v1/chat/completions",
        :body => request_body_json
      ).to_s

      pp @parsed_response = JSON.parse(raw_response)

      pp @reply = @parsed_response.dig("choices", 0, "message", "content")

      # pp @game_history << { "role" => "assistant", "content" => @reply }

      # cookies[:game_history] = JSON.generate(@game_history)


        
  # try this one out instead
    #   pp  @chat_history = JSON.parse(cookies[:chat_history] || "[]")

    #   pp  @current_message = params.fetch("user_chat_msg")

    #   pp  @chat_history << { "role" => "user", "content" => @current_message }

    #   pp  request_headers_hash = {
    #       "Authorization" => "Bearer #{ENV.fetch("OPENAI_API_KEY")}",
    #       "content-type" => "application/json"
    #     }


    #   pp request_messages = [
    #       {
    #         "role" => "system",
    #         "content" => "You can only respond in Russian in the form of cyrillic text."
    #       },
    #       {
    #         "role" => "user",
    #         "content" => @current_message
    #       }
    #     ]

    #   @chat_history.each do |message|
    #       request_messages << {
    #         "role" => message["role"],
    #         "content" => message["content"]
    #       }
    #     end

    #   pp  request_body_hash = {
    #       "model" => "gpt-3.5-turbo",
    #       "messages" => request_messages
    #     }

    #     pp request_body_json = JSON.generate(request_body_hash)

    #     pp raw_response = HTTP.headers(request_headers_hash).post(
    #       "https://api.openai.com/v1/chat/completions",
    #       :body => request_body_json
    #     ).to_s

    #     @parsed_response = JSON.parse(raw_response)

    #     @reply = @parsed_response.dig("choices", 0, "message", "content")

    #     @chat_history << { "role" => "assistant", "content" => @reply }


    #     cookies[:chat_history] = JSON.generate(@chat_history)
  # chatgpt_action
  pp session[:cookiepile1] ||= []
  pp session[:cookiepile2] ||= []
  pp session[:cookiepile3] ||= []
  pp session[:cookiepile4] ||= []
  session[:current_step_index_cookie] ||= []
  $dealer_deck
  pp $current_step_index += 0
  @piles = session[:piles] || distribute_to_piles($dealer_deck)
  @pile1 = @piles[0]
  @pile2 = @piles[1]
  @pile3 = @piles[2]
  @pile4 = @piles[3]

  if ((session[:current_step_index_cookie].length) == 1)
    session[:cookiepile1] += [@pile1.first]
  elsif ((session[:current_step_index_cookie].length) == 2)
    session[:cookiepile2] += [@pile2.first]
  elsif ((session[:current_step_index_cookie].length) == 3)
    session[:cookiepile3] += [@pile3.first]
  elsif ((session[:current_step_index_cookie].length) == 4)
    session[:cookiepile4] += [@pile4.first]
  else
    case $current_step_index
    when 0
      session[:cookiepile1] += [@pile1.first]
      @pile1.shift if @pile1.length > 1
    when 1
      @pile2.shift if @pile2.length > 1
      session[:cookiepile2] += [@pile2.first]
    when 2
      @pile3.shift if @pile3.length > 1
      session[:cookiepile3] += [@pile3.first]
    when 3
      @pile4.shift if @pile4.length > 1
      session[:cookiepile4] += [@pile4.first]
    end
  end

  # ideal_format
    # begin
    #   @game_history = JSON.parse(cookies[:game_history] || JSON.generate([]))
    # rescue JSON::ParserError => e
    #   # Handle the parsing error, for example, you could set an empty game history
    #   @game_history = []
    #   # You might want to log the error for debugging purposes
    #   puts "Error parsing game history JSON: #{e.message}"
    # end
    

    $state_of_play = [session[:cookiepile1], session[:cookiepile2], session[:cookiepile3], session[:cookiepile4], session[:current_step_index_cookie], cookies[:game_history]].to_s

    #   @game_history << { "role" => "user", "content" => $state_of_play.to_s }

      request_headers_hash = {
          "Authorization" => "Bearer #{ENV.fetch("OPENAI_API_KEY")}",
          "content-type" => "application/json"
        }

      request_messages = [
          {
            "role" => "system",
            "content" => $chatgpt_instructions
          },
          {
            "role" => "user",
            "content" => "$state_of_play = [session[:cookiepile1], session[:cookiepile2], session[:cookiepile3], session[:cookiepile4], session[:current_step_index_cookie], cookies[:game_history]]. Here is $state_of_play: #{$state_of_play}"
          }
        ]

      # @game_history.each do |message|
      #     request_messages << {
      #       "role" => message["role"],
      #       "content" => message["content"]
      #     }
      #   end

        request_body_hash = {
          "model" => "gpt-3.5-turbo",
          "messages" => request_messages
        }

        request_body_json = JSON.generate(request_body_hash)

        raw_response = HTTP.headers(request_headers_hash).post(
          "https://api.openai.com/v1/chat/completions",
          :body => request_body_json
        ).to_s

        pp @parsed_response = JSON.parse(raw_response)

        pp @reply = @parsed_response.dig("choices", 0, "message", "content")

        # pp @game_history << { "role" => "assistant", "content" => @reply }

        # cookies[:game_history] = JSON.generate(@game_history)


      
  $current_step_index += 1
  $current_step_index %= 4
  # Store the updated @piles array back into the session
  session[:piles] = @piles
  pp session[:cookiepile1] ||= []
  pp session[:cookiepile2] ||= []
  pp session[:cookiepile3] ||= []
  pp session[:cookiepile4] ||= []
  pp session[:current_step_index_cookie] << $current_step_index
  erb(:next_card)
end












# post("/first_pile") do
#   session[:cookiepile1] ||= []
#   session[:current_step_index_cookie] ||= []
#   pp $current_step_index ||= 0
#   $current_step_index += 0
#   $dealer_deck
#   @piles = session[:piles] || distribute_to_piles($dealer_deck)
#   @current_card_indices = current_card_indices
#   @pile1 = @piles[0]
#   @pile2 = @piles[1]
#   @pile3 = @piles[2]
#   @pile4 = @piles[3]

#   # Increment the index for the next step
#   $current_step_index += 1
#   $current_step_index %= 4
#   # Store the updated @piles array back into the session
#   session[:piles] = @piles
#   pp session[:cookiepile1] += [@pile1.first]
#   pp session[:current_step_index_cookie] += [$current_step_index]
#   erb(:first_pile)
# end

# post("/second_pile") do
#   session[:cookiepile1] ||= []
#   session[:cookiepile2] ||= []
#   session[:current_step_index_cookie] ||= []
#   $dealer_deck
#   @piles = session[:piles] || distribute_to_piles($dealer_deck)
#   @current_card_indices = current_card_indices
#   @pile1 = @piles[0]
#   @pile2 = @piles[1]
#   @pile3 = @piles[2]
#   @pile4 = @piles[3]

#   # Increment the index for the next step
#   $current_step_index += 1
#   $current_step_index %= 4
#   # Store the updated @piles array back into the session
#   session[:piles] = @piles
#   pp session[:cookiepile2] += [@pile2.first]
#   pp session[:current_step_index_cookie] += [$current_step_index]
#   @pile2
#   erb(:second_pile)
# end

# post("/third_pile") do
#   session[:cookiepile1] ||= []
#   session[:cookiepile2] ||= []
#   session[:cookiepile3] ||= []
#   session[:current_step_index_cookie] ||= []
#   $dealer_deck
#   @piles = session[:piles] || distribute_to_piles($dealer_deck)
#   @current_card_indices = current_card_indices
#   @pile1 = @piles[0]
#   @pile2 = @piles[1]
#   @pile3 = @piles[2]
#   @pile4 = @piles[3]

#   # Increment the index for the next step
#   $current_step_index += 1
#   $current_step_index %= 4
#   # Store the updated @piles array back into the session
#   session[:piles] = @piles
#   session[:cookiepile1]
#   session[:cookiepile2]
#   pp session[:cookiepile3] += [@pile3.first]
#   pp session[:current_step_index_cookie] += [$current_step_index]
#   @pile3
#   erb(:third_pile)
# end

# post("/fourth_pile") do
#   session[:cookiepile1] ||= []
#   session[:cookiepile2] ||= []
#   session[:cookiepile3] ||= []
#   session[:cookiepile4] ||= []
#   session[:current_step_index_cookie] ||= []
#   $dealer_deck
#   @piles = session[:piles] || distribute_to_piles($dealer_deck)
#   @current_card_indices = current_card_indices
#   @pile1 = @piles[0]
#   @pile2 = @piles[1]
#   @pile3 = @piles[2]
#   @pile4 = @piles[3]

#   # Increment the index for the next step
#   $current_step_index += 1
#   $current_step_index %= 4
#   # Store the updated @piles array back into the session
#   session[:piles] = @piles
#   session[:cookiepile1]
#   session[:cookiepile2]
#   session[:cookiepile3]
#   pp session[:cookiepile4] += [@pile4.first]
#   pp session[:current_step_index_cookie] += [$current_step_index]
#   @pile4
#   erb(:fourth_pile)
# end
