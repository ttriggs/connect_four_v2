class Board
  attr_reader :left_pad, :top_pad, :area, :cell_dim
  attr_accessor :board_data
  ROW_COUNT = 6
  COL_COUNT = 7
  CELL_DIM  = 62
  LEFT_PAD  = 82
  TOP_PAD   = 82

  def initialize(window)
    @window = window
    @open_cell_image  = Gosu::Image.new(@window, "img/circle_grey.png")
    @board_data = initialize_board_data
    @row_count = ROW_COUNT
    @col_count = COL_COUNT
    @cell_dim  = CELL_DIM
    @left_pad  = LEFT_PAD
    @top_pad   = TOP_PAD
    @state = :draw_board
    width  = @col_count * CELL_DIM
    height = @row_count * CELL_DIM
    @area  = BoundingBox.new(@left_pad, @top_pad, width, height)
  end

  def initialize_board_data
    (0...COL_COUNT).each_with_object([]) do |col, array|
      (0...ROW_COUNT).each do |row|
        array << Cell.new(col, row, 0, @open_cell_image)
      end
    end
  end

  def draw
    draw_full_board
    if @state == :animate_drop
      increment_animation
    end
  end

  def draw_full_board
    @board_data.each do |cell|
      x = cell_x(cell)
      y = cell_y(cell)
      cell.image.draw(x, y, 1)
    end
  end

  def animate_drop_token_for(player, cell)
    @original_state = @window.state
    @state, @window.state = :animate_drop
    @cell_y_pos = TOP_PAD - CELL_DIM
    @cell_x_pos = cell_x(cell)
    @cell_y_end = cell_y(cell)
    @cell = cell
    @player = player
    @cell_to_animate = Cell.for_animation(cell, player.number, player.image)
  end

  def increment_animation
    if @cell_y_pos < @cell_y_end
      @cell_to_animate.image.draw(@cell_x_pos, @cell_y_pos, 1)
      @cell_y_pos += 10
    else
      @state = :draw_board
      @window.state = @original_state
      @cell.owner = @player.number
      @cell.image = @player.image
      @window.finish_turn
    end
  end

  def cell_x(cell)
    (cell.col * CELL_DIM) + @left_pad
  end

  def cell_y(cell)
    (cell.row * CELL_DIM) + @top_pad
  end
end

