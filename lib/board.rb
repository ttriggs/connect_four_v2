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
    cells = []

    (0...COL_COUNT).each do |col|
      (0...ROW_COUNT).each do |row|
        cell = Cell.new(col, row, 0, @open_cell)
        cells << cell
      end
    end
    cells
    # you can use #each_with_object to refactor this to this:
    # (0...COL_COUNT).each_with_object([]) do |col, arr|
    #   (0...ROW_COUNT).each do |row|
    #     arr << Cell.new(col, row, 0, @open_cell)
    #   end
    # end
    # it will then return the built array for you
  end

  def draw
    @board_data.each do |cell|
      x = (cell.col * CELL_DIM) + @left_pad
      y = (cell.row * CELL_DIM) + @top_pad
      cell.image.draw(x, y, 1)
    end
  end
end



