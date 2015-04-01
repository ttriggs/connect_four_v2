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
    @ai_picker.pick_col_for_AI
  end
end
