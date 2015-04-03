class Board
  attr_reader :left_pad, :top_pad, :area, :cell_dim
  attr_accessor :board_data
  ROW_COUNT = 6
  COL_COUNT = 7
  CELL_DIM  = 62
  LEFT_PAD  = 82
  TOP_PAD   = 82

  def initialize(window)
    @open_cell  = Gosu::Image.new(window, "img/circle_grey.png")
    @board_data = initialize_board_data
    @row_count = ROW_COUNT
    @col_count = COL_COUNT
    @cell_dim  = CELL_DIM
    @left_pad  = LEFT_PAD
    @top_pad   = TOP_PAD
    width  = @col_count * CELL_DIM
    height = @row_count * CELL_DIM
    @area  = BoundingBox.new(@left_pad, @top_pad, width, height)
  end

  def initialize_board_data
    (0...COL_COUNT).each_with_object([]) do |col, array|
      (0...ROW_COUNT).each do |row|
        array << Cell.new(col, row, 0, @open_cell)
      end
    end
  end

  def draw
    @board_data.each do |cell|
      x = (cell.col * CELL_DIM) + @left_pad
      y = (cell.row * CELL_DIM) + @top_pad
      cell.image.draw(x, y, 1)
    end
  end
end



