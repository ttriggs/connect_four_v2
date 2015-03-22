class AIPicker
  def initialize(player, window, board_logic)
    @player = player
    @window = window
    @board_logic = board_logic
    @board_data = @board_logic.board_data
    @board_patterns = [] # used in simulations
  end

  def opponent
    @window.opponent(@player)
  end

  def pick_col_for_AI
    if @player.difficulty == GameWindow::BABY
      baby_AI_pick_col
    else
      harder_AIs_pick_col
    end
  end

  def baby_AI_pick_col
    random_col = @board_logic.next_open_cells
    random_col = random_col.sample.col
    @board_logic.fill_cell(random_col, @player)
  end

  def intersect_ranking_with_opens(next_opens)
    @player.col_rank.keep_if do |col, _|
      next_opens.any? {|cell| col == cell.col }
    end
  end

  def harder_AIs_pick_col
    # this method looks too big, figure out a way to break it up into smaller
    # methods

    difficulty = @player.difficulty
    number     = @player.number
    opp_num    = @window.opponent(@player).number
    next_opens = @board_logic.next_open_cells
    intersect_ranking_with_opens(next_opens)
    next_opens.map do |cell|
      @player.rank_guide.each do |settings, pos_pats, neg_pats|
        lookahead, pos_amount, neg_amount = settings
        # skip looking ahead for lesser AIs
        next if lookahead > difficulty - 2
        rank_col(cell.col, number, difficulty, pos_pats, pos_amount, opp_num, neg_pats, neg_amount)
      end
    end
    best_col = @player.col_rank.max_by { |rank| rank[1].to_i }[0]
    @board_logic.fill_cell(best_col, @player)
  end


  def simulate_fill(col, cells, number)
    opens_in_col = cells.select  { |cell| cell[:col] == col && cell[:owner] == 0 }
    cell = opens_in_col.max_by { |cell| cell[:row] }
    cell[:owner] = number
  end

  def update_board_patterns(cells)
    @board_patterns = @board_logic.get_board_patterns(cells)
  end

  def rank_col(col, player_num, difficulty, pos_pats, pos_amount, opp_num, neg_pats, neg_amount)
    # this method looks too big too. Figure out how to break it up
    [[player_num, pos_pats, pos_amount], [opp_num, neg_pats, neg_amount]].each do |pnum, pats, amount|
      sim_cells = @board_logic.sandbox_board_data
      simulate_fill(col, sim_cells, pnum)
      update_board_patterns(sim_cells)
      pats.each do |pat|
        @board_patterns.each do |pattern|
          # skip checking diagonals for lesser AIs
          next if difficulty < GameWindow::EXPERT && pattern.include?("diag")
          add_col_rank(col, amount) if pattern.include?(pat)
        end
      end
    end
  end

  def add_col_rank(col, amount)
    @player.col_rank.each { |ar| ar[1] += amount if ar[0] == col.to_i }
  end
end


