class Player
  attr_reader :number, :image
  def initialize( number, image, board_logic, window)
    @number = number
    @image  = image
    @board_logic = board_logic
    @window = window
  end

  # seems like players should probably have more logic/methods 
  # associated with it
end

