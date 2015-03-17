class Human < Player
  def initialize(number, image, board_logic, window)
    super(number, image, board_logic, window)
  end

  def take_turn(col)
    if @board_logic.any_open_in_col?(col)
      @board_logic.fill_cell(col, self)
    else
      false
    end
  end

end
