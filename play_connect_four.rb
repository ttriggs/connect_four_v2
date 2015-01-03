#!/usr/bin/env ruby
require './game.rb'
require './board.rb'
require './player.rb'


#gameplay:
game    = Game.new
board		= Board.new(game)
player1 = game.set_player_type(1,"o")
player2 = game.set_player_type(2,"x")

game.setup_turn_queue(player1,player2,board)

while board.check_for_winner == false
  board.display_board
  game.active_player.take_turn(board)
  board.advance_turn_counter
  game.reverse_turn_queue
end
