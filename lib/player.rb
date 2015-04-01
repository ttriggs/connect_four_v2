class Player
  attr_reader :number, :image, :difficulty
  def initialize(number, difficulty, image, window, board_logic)
    @number = number
    @image  = image
    @difficulty = difficulty
    @board_logic = board_logic
    @window = window
    @ai_picker = AIPicker.new(self, window, board_logic) if difficulty > 1
  end

  def take_turn(col = "")
    if difficulty == 1
      human_take_turn(col)
    else
      @ai_picker.pick_col_for_AI
      @window.finish_turn
    end
  end

  def human_take_turn(col)
    if @board_logic.any_open_in_col?(col)
      @board_logic.fill_cell(col, self)
      @window.finish_turn
    end
  end
end



