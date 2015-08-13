class AIPicker
  def initialize(player, window, board_logic)
    @window      = window
    @board_logic = board_logic
    @player      = player
    @my_number   = player.number
    @difficulty  = player.difficulty
    @lookahead_weighting = {1 => [1050, 1000], 2 => [100, 70], 3 => [40, 0]}
    @generic_goal_patterns = [["XXXX"],
                             ["0XXX", "X0XX", "XX0X", "XXX0"],
                             ["00XX", "0X0X", "0XX0", "X0X0", "XX00"]]
  end

  def gen_goal_patterns(patterns, player_number)
    patterns.map {|pattern| pattern.gsub(/X/, "#{player_number}")}
  end

  def gen_ai_patterns(string_patterns, replace_num)
    string_patterns.each { |x| x.each { |y| y.gsub!(/X/, "#{replace_num}") } }
  end

  def initialize_opponent_number(number)
    number == 1 ? 2 : 1
  end

  def pick_col_for_AI
    @open_cells = get_open_cells
    if @difficulty == GameWindow::EASY
      col = pick_col_for_easy_AI
    else
      resest_baseline_rankings
      @op_number  ||= initialize_opponent_number(@my_number)
      @rank_guide ||= initialize_rank_guide
      simulate_and_eval_outcomes_for_open_cells
      col = pick_col_for_harder_AIs
    end
    col
  end

  def pick_col_for_easy_AI
    @open_cells.sample.col
  end

  def pick_col_for_harder_AIs
    @col_rank.max_by { |col, rank| rank }[0]
  end

  def simulate_and_eval_outcomes_for_open_cells
    @open_cells.each do |cell|
      simulate_my_and_opponent_move(cell)
    end
  end

  def simulate_my_and_opponent_move(cell)
    @rank_guide.each do |lookahead_hash|
      ["op", "my"].each do |type|
        @sim_cells = @board_logic.sandbox_board_data
        update_col_rank(cell, lookahead_hash, type)
      end
    end
  end

  def update_col_rank(cell, lookahead_hash, type)
    weight      = lookahead_hash["#{type}_weight".to_sym]
    player_number = lookahead_hash["#{type}_number".to_sym]
    search_patterns = lookahead_hash["#{type}_patterns".to_sym]
    simulate_fill_cell(cell, player_number)
    board_patterns = get_new_board_patterns
    if fuzzy_include?(board_patterns, search_patterns)
      @col_rank[cell.col] += weight
    end
  end

  def fuzzy_include?(board_patterns, search_patterns)
    board_patterns.map do |bp|
      search_patterns.any? do |pattern|
        bp.include?(pattern)
      end
    end.any?
  end

  def get_new_board_patterns
    @board_logic.get_board_patterns(@sim_cells).map do |pattern|
      pattern.split("-").first
    end
  end

  def simulate_fill_cell(cell, player_number)
    @sim_cells.find do |sim_cell|
      sim_cell[:col] == cell.col && sim_cell[:row] == cell.row
    end[:owner] = player_number
  end

  def initialize_rank_guide
    array = []
    @generic_goal_patterns.each.with_index(1) do |patterns, lookahead|
      my_patterns = gen_goal_patterns(patterns, @my_number)
      op_patterns = gen_goal_patterns(patterns, @op_number)
      next if lookahead >= @difficulty - 1
      array << { lookahead: lookahead,
                 my_patterns: my_patterns, op_patterns: op_patterns,
                 my_number: @my_number, op_number: @op_number,
                 my_weight: @lookahead_weighting[lookahead][0],
                 op_weight: @lookahead_weighting[lookahead][1] }
    end
    array
  end

  def get_open_cells
    @board_logic.next_open_cells
  end

  def resest_baseline_rankings
    @col_rank  = {0 => 10, 1 => 21, 2 => 30, 3 => 40,
                  4 => 31, 5 => 20, 6 => 11}
    add_rank_noise unless expert?
    filter_for_columns_in_play
  end

  def add_rank_noise
    @col_rank.update(@col_rank) { |_col, value| value += rand(-10..20) }
  end

  def filter_for_columns_in_play
    @col_rank.keep_if do |col, _|
      @open_cells.any? {|cell| col == cell.col }
    end
  end

  def expert?
    @difficulty == GameWindow::EXPERT
  end
end


