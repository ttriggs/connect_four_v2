class Player
  attr_reader :number, :image, :difficulty
  def initialize(number, difficulty, image, window, board_logic)
    @number = number
    @image  = image
    human = GameWindow::HUMAN
    @difficulty = difficulty
    @board_logic = board_logic
    @window = window
    @ai_picker = AIPicker.new(self, window, board_logic) if difficulty != human
  end

  def take_turn(col = "")
    if player_human?
      human_take_turn(col)
    else
      col = @ai_picker.pick_col_for_AI
      @board_logic.fill_cell(col, self)
    end
  end

  def human_take_turn(col)
    if @board_logic.any_open_in_col?(col)
      @board_logic.fill_cell(col, self)
    end
  end

  def player_human?
    @difficulty == 1
  end
end



