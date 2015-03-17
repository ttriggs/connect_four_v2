class Player
  attr_reader :number, :image
  def initialize( number, image, board_logic, window)
    @number = number
    @image  = image
    @board_logic = board_logic
    @window = window
  end
end

