class Board
  attr_accessor :board_data
  ROW_COUNT = 6
  COL_COUNT = 7
  CELL_DIM  = 62
  LEFT_PAD  = 82
  TOP_PAD   = 82

  def initialize(window)
    @window = window
    @board_data = initialize_board_data
    @state = :draw_board
    width  = COL_COUNT * CELL_DIM
    height = ROW_COUNT * CELL_DIM
    @area  = BoundingBox.new(LEFT_PAD, TOP_PAD, width, height)
  end

  def open_cell_image
    @open_cell_image ||= Gosu::Image.new("img/circle_grey.png")
  end

  def initialize_board_data
    (0...COL_COUNT).each_with_object([]) do |col, array|
      (0...ROW_COUNT).each do |row|
        array << Cell.new(col, row, 0, open_cell_image)
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

  def clicked_col(mouse_x, mouse_y)
    if @area.click_within?(mouse_x, mouse_y)
      screen_coord_to_col(mouse_x)
    end
  end

  def screen_coord_to_col(x)
    ((x - LEFT_PAD) / CELL_DIM).to_i
  end

  def cell_x(cell)
    (cell.col * CELL_DIM) + LEFT_PAD
  end

  def cell_y(cell)
    (cell.row * CELL_DIM) + TOP_PAD
  end
end

