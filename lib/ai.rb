class AI < Player
  attr_reader :difficulty
  attr_accessor :col_rank
  def initialize( number, image, board_logic, window, difficulty)
    super( number, image, board_logic, window)
    @board_logic = board_logic
    @difficulty = difficulty
    @ai_picker = AIPicker.new(self, window, board_logic)
  end

  def take_turn
    #reset baseline column rankings for each turn
    # @col_rank  = [[0, 10], [1, 21], [2, 30], [3, 40], [4, 31], [5, 20], [6, 11]]
    # add_rank_noise unless expert?
    @ai_picker.pick_col_for_AI
  end

  # def add_rank_noise
  #   @col_rank.each  { |rank| rank[1] += rand(-10..20) }
  # end

  # def expert?
  #   @difficulty == @window.expert_difficulty
  # end
end
