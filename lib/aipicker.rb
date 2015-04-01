class AIPicker
  def initialize(player, window, board_logic)
    @player = player
    @number = player.number
    @window = window
    @difficulty = player.difficulty
    @player_number = player.number
    @board_logic = board_logic
    @board_data  = board_logic.board_data
    @board_patterns = []  # used in simulations
    # @rank_guide = initialize_rank_guide
  end

  def initialize_rank_guide
    goal_patterns = [["XXXX"],
                    ["0XXX", "X0XX", "XX0X", "XXX0"],
                    ["00XX", "0X0X", "0XX0", "X0X0", "XX00"]]  # to recognize patterns
    pos_pats = gen_ai_patterns(@window.deep_copy(goal_patterns), @number)
    neg_pats = gen_ai_patterns(@window.deep_copy(goal_patterns), opponent_number)
              # [0]=num moves ahead, [1]=add value(if AI move) [2]=add value(opponent move)
    [[1, 1050, 1000], [2, 100, 70], [3, 20, 0]].zip(pos_pats, neg_pats)
  end

  def gen_ai_patterns(string_patterns, replace_num)
    string_patterns.each { |x| x.each { |y| y.gsub!(/X/, "#{replace_num}") } }
  end

  def opponent_number
    @number == 1 ? 2 : 1
  end

  # def opponent
  #   @window.(@player)
  # end

  def pick_col_for_AI
    @col_rank  = [[0, 10], [1, 21], [2, 30], [3, 40], [4, 31], [5, 20], [6, 11]]
    add_rank_noise unless expert?

    if @difficulty == @window.baby_difficulty
      baby_AI_pick_col
    else
      harder_AIs_pick_col
    end
  end

  def baby_AI_pick_col
    random_col = @board_logic.next_open_cells.sample.col
    @board_logic.fill_cell(random_col, @player)
  end

  def intersect_ranking_with_opens(next_opens)
    @col_rank.keep_if do |col, _|
      next_opens.any? {|cell| col == cell.col }
    end
  end

  # get next open cells
  #

  def harder_AIs_pick_col
    next_opens = @board_logic.next_open_cells
    intersect_ranking_with_opens(next_opens)
    @rank_guide      ||= initialize_rank_guide
    next_opens.map do |cell|
      @rank_guide.each do |settings, pos_pats, neg_pats|
        lookahead, pos_amount, neg_amount = settings
        # skip looking ahead for lesser AIs
        next if lookahead > @difficulty - 2
        rank_col(cell.col, @difficulty, pos_pats, pos_amount, neg_pats, neg_amount)
      end
    end
    best_col = @col_rank.max_by { |rank| rank[1].to_i }[0]
    @board_logic.fill_cell(best_col, @player)
  end


  def simulate_fill(col, cells, pnum)
    opens_in_col = cells.select  { |cell| cell[:col] == col && cell[:owner] == 0 }
    cell = opens_in_col.max_by { |cell| cell[:row] }
    cell[:owner] = pnum
  end

  def update_board_patterns(cells)
    @board_patterns = @board_logic.get_board_patterns(cells)
  end

  def rank_col(col, difficulty, pos_pats, pos_amount, neg_pats, neg_amount)
    [[@player_number, pos_pats, pos_amount], [opponent_number, neg_pats, neg_amount]].each do |pnum, pats, amount|
      sim_cells = @board_logic.sandbox_board_data
      simulate_fill(col, sim_cells, pnum)
      update_board_patterns(sim_cells)
      pats.each do |pat|
        @board_patterns.each do |pattern|
          # skip checking diagonals for lesser AIs
          next if difficulty < @window.expert_difficulty && pattern.include?("diag")
          add_col_rank(col, amount) if pattern.include?(pat)
        end
      end
    end
  end

  def expert?
    @difficulty == @window.expert_difficulty
  end

  def add_rank_noise
    @col_rank.each  { |rank| rank[1] += rand(-10..20) }
  end

  def add_col_rank(col, amount)
    @col_rank.each { |ar| ar[1] += amount if ar[0] == col.to_i }
  end
end


