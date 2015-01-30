#!/usr/bin/env ruby

class Board
  WINCOUNT = 4  # it's connect four, right?

  def initialize(game_obj)
    #Nice splash screen :D
@show_title = <<EOS
                                 _      __
  ___ ___  _ __  _ __   ___  ___| |_   / _| ___  _   _ _ __
 / __/ _ X| '_ X| '_ X / _ X/ __| __| | |_ / _ X| | | | '__|
| (_| (_) | | | | | | |  __/ (__| |_  |  _| (_) | |_| | |
 X___X___/|_| |_|_| |_|X___|X___|X__| |_|  X___/ X__,_|_|
EOS


@play_board = <<EOS
_______________
| | | | | | | |
|-|-|-|-|-|-|-|
| | | | | | | |
|-|-|-|-|-|-|-|
| | | | | | | |
|-|-|-|-|-|-|-|
| | | | | | | |
|-|-|-|-|-|-|-|
| | | | | | | |
|-|-|-|-|-|-|-|
| | | | | | | |
|-|-|-|-|-|-|-|
_1_2_3_4_5_6_7_
EOS
    @game_obj      = game_obj
    @winner        = 0
    @play_board    = @play_board.split("\n")
    @writable_rows = [1, 3, 5, 7, 9, 11]
    @writable_cols = [1, 3, 5, 7, 9, 11, 13]
    @board_cells   = []
    @turn_count    = 0
    @message       = ""

    # setup open cells array
    # can you reduce the nested each_with_index's here?
    # it's a bit confusing to read
    @writable_rows.each_with_index do |orow, row_i|
      @writable_cols.each_with_index do |ocol, col_i|
        @board_cells.push([orow, row_i + 1, ocol, col_i + 1, 0])
      end
    end

    headers_ar   = ['row', 'row_i', 'col', 'col_i', 'filled']
    #variable instantiating usually happens in one place for readibility
    @cell_header = Hash.new
    headers_ar.each_with_index { |header, i| @cell_header[header] = i }
  end

  #look into attr_reader, attr_writer and attr_accessor so you don't have
  # to make your own method for this. Instead you could just call
  # variable.message to return the message. Same thing for some of the other
  # methods below.
  def set_message(message)
    @message = message
  end

  def deep_copy_array(array)
    @game_obj.deep_copy_array(array)
  end

  def opp_player_num(player_num)
    @game_obj.opp_player_num(player_num)
  end

  def opp_player_obj(player_obj)
    @game_obj.opp_player_obj(player_obj)
  end

  def board_cells
    @board_cells
  end

  def advance_turn_counter
    @turn_count += 1
  end

  def display_board
    system "clear"
    puts @show_title.gsub("X", '\\')
    puts @play_board
    puts "turn count: #{@turn_count / 2} \n#{@message}"
  end

  def refresh_board_patterns(test_cells = @board_cells)
    # create arr for filled cell patterns to for winner or AI analysis
    @board_patterns = []
    rows_to_board_patterns(test_cells)
    # rotate array to diamond shape using diag meth to look for win patterns
    right_diag_pats = diagonalize(@filled_cells)
    left_diag_pats  = diagonalize(@filled_cells.reverse)
    diag_to_board_patterns(left_diag_pats, right_diag_pats)
    @board_patterns
  end

  def rows_to_board_patterns(test_cells)
    @filled_cells    = [] # used in diagonal goal testing
    rowcol_ar = [['row', @writable_rows], ['col', @writable_cols]]
    #Here you have an .each, .each_with_index and flow control
    #I would think about how you can break up all this code into
    #more readable code.
    rowcol_ar.each do |dir, array|
      array.each_with_index do |posN, i|
        pattern = test_cells.select { |a| a[@cell_header[dir]] == posN }.collect { |a| a[@cell_header['filled']] }
        @board_patterns.push([pattern, "-#{dir}.#{i + 1}"].join)
        if dir == 'row'
          @filled_cells.push(pattern)
        end
      end
    end
  end

  def diagonalize(filled_cells)
    #This is rather difficult to understand what's going on here
    #The beauty of Ruby is its readability. It is fun to chain
    #ruby methods one after the other (transpose.flatten.etc.etc)
    #but what this does, it makes code difficult to understand
    #It's ok to have a long, readable method rather than a short
    #one that requires analysis.
    filled_cells.transpose.flatten.group_by.with_index { |_, k|
      k.divmod(filled_cells.size).inject(:+) }.values.select { |a| a if a.length >= WINCOUNT }
  end

  def diag_to_board_patterns(left_diag_pats, right_diag_pats)
    diag_ar = [['rdiag', right_diag_pats], ['ldiag', left_diag_pats]]
    #Here is a question that you should ask yourself. If you have so many
    #nested .each / .each_with_index's, do you think you are using the
    #right data structures?
    diag_ar.each do |name, multi_ar|
      multi_ar.each_with_index do |subar, i|
        @board_patterns.push([subar, "-#{name}.#{i}"].join)
      end
    end
  end

  def check_for_winner
    return false if @turn_count == 0
    [1, 2].each do |player|
      refresh_board_patterns
      win_pat = "#{player}" * WINCOUNT
      @board_patterns.each do |pattern|
        next unless pattern.include?(win_pat)
        game_over("#{player}    4-in-a-row!: #{pattern}")
      end
      game_over("Tie") if @board_cells.select { |a| a[@cell_header['filled']] == 0 }.empty?
    end
    return false
  end

  def next_open_cells(test_cells = @board_cells)
    @writable_cols.reduce([]) do |open_cells, col|
      cell = test_cells.select { |a|
        a[@cell_header['col']] == col &&
        a[@cell_header['filled']] == 0 }.max # maxed=lowest open row pos in col
      open_cells << cell if cell
      open_cells
    end
  end

  def open_cell_in_col(col_i, test_cells = @board_cells)
    #name your variables something meaningful
    #I'm not sure what 'ar' is here on its own
    next_open_cells(test_cells).select { |ar| ar[@cell_header['col_i']] == col_i }
  end

  def drop_piece(col_i, player_num, test_cells = @board_cells, type = "gameplay", token = "")
    #cell_to_fill might be a more rubyesque way to name that variable
    cell2fill   = open_cell_in_col(col_i, test_cells)[0]
    cell2fill[@cell_header['filled']] = player_num
    if type == "gameplay"
      c2frow, c2fcol = cell2fill[@cell_header['row']], cell2fill[@cell_header['col']]
      @play_board[c2frow][c2fcol] = token
      @message = "[Last turn, Player #{player_num} chose column #{col_i}]"
    end
  end

  def pick_col_for_AI(player_obj)
    player_num, token, _, difficulty,@player_col_rank = player_obj.show_info
    opp_player_obj      = opp_player_obj(player_obj)
    opp_num, _          = opp_player_obj.show_info
    @player_col_rank  	= col_rank_intersect(next_open_cells)
    puts "Player #{player_num}: AI is thinking of next move..."
    sleep 1
    if difficulty == 1
      baby_AI_pick_col(player_num, token)
    else
      harder_AIs_pick_col(player_obj, player_num, opp_num, token, difficulty)
    end
  end

  def col_rank_intersect(open_cells)
    @player_col_rank = @player_col_rank.find_all { |col_i, _|
      open_cells.find  { |ar| ar[@cell_header['col_i']] == col_i } }
  end

  def baby_AI_pick_col(player_num, token)
    random_col = next_open_cells.sample[@cell_header['col_i']]
    drop_piece(random_col, player_num, @board_cells, "gameplay", token)
  end

  def harder_AIs_pick_col(player_obj, player_num, opp_num, token, difficulty)
    # in Ruby, in general, if you are commenting your code, it probably
    # means that you can make the code more readable. Again, with all the
    # nested iteration here, it is hard to follow
    next_open_cells.each do |open_cell|
      col_i = open_cell[@cell_header['col_i']]
      player_obj.rank_guide.each do |settings, pos_pats, neg_pats|
        lookahead, pos_amount, neg_amount = settings
        next if lookahead > difficulty - 1   # skip looking moves ahead for lesser AIs
        rank_col(col_i, player_num, difficulty, pos_pats, pos_amount, opp_num, neg_pats, neg_amount)
      end
    end
    best_col = @player_col_rank.max_by { |rank| rank[1].to_i }[0]
    drop_piece(best_col, player_num, @board_cells, "gameplay", token)
  end

  def rank_col(col_i, player_num, difficulty, pos_pats, pos_amount, opp_num, neg_pats, neg_amount)
    # break out of all these .each's
    # In your code, you do a lot of method calling other methods
    # In general, this is bad practice because it makes it hard to
    # troubleshoot your code
    [[player_num, pos_pats, pos_amount], [opp_num, neg_pats, neg_amount]].each do |pnum, pats, amount|
      sim_cells = deep_copy_array(@board_cells)
      drop_piece(col_i, pnum, sim_cells, "simulate")
      refresh_board_patterns(sim_cells)
      pats.each do |pat|
        @board_patterns.each do |bp|
          next if difficulty < 4 && bp.include?("diag") # skip checking diagonals for lesser AIs
          add_col_rank(col_i, amount) if bp.include?(pat)
        end
      end
    end
  end

  def add_col_rank(column, amount)
    @player_col_rank.each { |ar| ar[1] += amount if ar[0] == column.to_i }
  end

  def game_over(result)
    display_board
    puts "\nGAME OVER..."
    if result == "Tie"
      puts "\tGame ended in a Tie"
    else
      puts "WINNER: player #{result}"
    end
    abort("")
  end
end
