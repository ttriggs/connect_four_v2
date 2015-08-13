class Player
  attr_reader :number, :image, :difficulty

  def initialize(number, difficulty, window, board_logic)
    @number = number
    @window = window
    @image  = set_image
    @difficulty = difficulty
    @board_logic = board_logic
  end

  def take_turn(col = "")
    if human?
      human_take_turn(col)
    else
      col = ai_picker.pick_col_for_AI
      @board_logic.fill_cell(col, self)
    end
  end

  def ai_picker
    @ai_picker ||= AIPicker.new(self, @window, @board_logic)
  end

  def set_image
    @number == 1 ? game_token("red") : game_token("blue")
  end

  def game_token(color)
    Gosu::Image.new("img/circle_#{color}.png")
  end

  def human_take_turn(col)
    if @board_logic.any_open_in_col?(col)
      @board_logic.fill_cell(col, self)
    end
  end

  def human?
    @difficulty == GameWindow::HUMAN
  end

  def ai?
    !human?
  end
end
