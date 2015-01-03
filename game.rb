#!/usr/bin/env ruby

class Game
  def initialize
  end

  def get_user_answer(possible_answers)
    answer = ""
    while answer == ""
      answer = gets.chomp.to_i
      if possible_answers.include?(answer)
        return answer
      else
        answer = ""
        puts "Sorry, could you please try that answer again? possible choices are: #{possible_answers}"
      end
    end
  end

  def set_player_type(player_num,token)
    puts "\nWhat type of player is player #{player_num}?: 1=CPU 2=Human"
    player_type = get_user_answer([1,2])
    if player_type == 1
      puts "How difficult would you like player #{player_num} opponent to be?"
      puts "	 1=Baby   2=Child    3=Intermediate   4=Expert"
      difficulty = get_user_answer([1,2,3,4])
      AI.new(player_num,token,difficulty,self)
    else
      Human.new(player_num,token,self)
    end
  end

  def deep_copy_array(array)
    Marshal.load(Marshal.dump(array))
  end

  def opp_player_num(player_num)
    ([1,2] - [player_num])[0].to_s
  end

  def opp_player_obj(player_obj)
    (@turn_queue - [player_obj])[0]
  end

  def reverse_turn_queue
    @turn_queue.reverse!
  end

  def setup_turn_queue(player1,player2,board_obj)
    first_player  = [player1,player2].sample
    second_player = ([player1,player2] - [first_player])[0]
    @turn_queue   = [first_player, second_player]
    board_obj.set_message("Coin flip... Player #{active_player.show_player_num} wins and will take the first turn!")
  end

  def active_player
    @turn_queue[0]
  end

end
