#!/usr/bin/env ruby

class Player
  def initialize(player_num,token,game_obj)
    @token       = token
    @player_num  = player_num
    @game_obj    = game_obj
  end

  def deep_copy_array(array)
    @game_obj.deep_copy_array(array)
  end

  def opp_player_num(player_num)
    @game_obj.opp_player_num(player_num)
  end

  def show_player_num
    [@player_num]
  end

  def show_info
    [@player_num, @token, self]
  end
end


class Human < Player
  def initialize(player_num,token,game_obj)
    super
  end

  def take_turn(board_obj)
    player_num, token = show_info
    puts "Player #{player_num}: choose an open column:"
    col_i = gets.chomp.to_i
    while board_obj.open_cell_in_col(col_i).any? == false
      puts "\t Sorry, there are no openings in column #{col_i} ...pick again"
      col_i = gets.chomp.to_i
    end
    board_obj.drop_piece(col_i,player_num,board_obj.board_cells,"gameplay",token)
  end
end


class AI < Player
  def initialize(player_num,token,difficulty,game_obj)
    super(player_num,token,game_obj)
    goal_pats = [["XXXX"],
                ["0XXX", "X0XX", "XX0X", "XXX0"],
                ["00XX", "0X0X", "0XX0", "X0X0", "XX00"]] #"X00X" least helpful move
    opp_player_num = opp_player_num(player_num)
    pos_pats       = gen_ai_patterns(deep_copy_array(goal_pats),player_num)
    neg_pats       = gen_ai_patterns(deep_copy_array(goal_pats),opp_player_num)
    @rank_guide    = [[1,1010,1000],[2,40,30],[3,20,0]].zip(pos_pats,neg_pats)  #[0]=num moves ahead, [1]=add value(pos) [2]=add value(neg)
    @difficulty    = difficulty
  end

  def gen_ai_patterns(str_pats,replace_num)
     str_pats.each {|x| x.each {|y| y.gsub!(/X/,"#{replace_num}")}}
  end

  def show_info
    [@player_num, @token, self, @difficulty,@col_rank]
  end

  def rank_guide
    @rank_guide
  end

  def add_rank_noise
    @col_rank.each  {|rank| rank[1] += rand(-10..20)}
  end

  def take_turn(board_obj)
    @col_rank  = [[1,10],[2,21],[3,30],[4,40],[5,31],[6,20],[7,11]]
    add_rank_noise if @difficulty < 4
    board_obj.pick_col_for_AI(self)
  end
end
