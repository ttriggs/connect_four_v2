class BoardLogic
  WINCOUNT = 4  # it's connect four, right?
  attr_reader :board_data
  def initialize(window, board)
    @window = window
    @board = board
    @board_data = @board.board_data
  end

  def sandbox_board_data
    sandbox = @board_data.map do |cell|
      { col: cell.col, row: cell.row, owner: cell.owner }
    end
  end

  def get_board_patterns(cells = sandbox_board_data)
    board_patterns = []
    row_owners      = get_row_owners(cells)
    board_patterns += get_row_patterns(cells)
    board_patterns += get_col_patterns(cells)
    board_patterns += get_diagonal_patterns(row_owners)
  end

  def get_col_patterns(cells)
    patterns = (0...Board::COL_COUNT).map do |col|
      cells.map  {|cell| cell[:owner] if cell[:col] == col }.compact
    end
    patterns.map.with_index(0) {|col, i| col.join("") + "-col.#{i}" }
  end

  def get_row_patterns(cells)
    get_row_owners(cells).map.with_index(0) {|row, i| row.join("") + "-row.#{i}" }
  end

  def get_row_owners(cells)
    row_owners = (0...Board::ROW_COUNT).map do |row|
      cells.map { |cell| cell[:owner] if cell[:row] == row }.compact
    end
  end

  def diagonalize(row_patterns)
    return row_patterns.transpose.flatten.group_by.with_index { |_, k|
      k.divmod(row_patterns.size).inject(:+) }.values.select { |a| a if a.length >= WINCOUNT }
  end

  def get_diagonal_patterns(row_patterns)
    patterns = join_patterns('rdiag', diagonalize(row_patterns))
    patterns += join_patterns('ldiag', diagonalize(row_patterns.reverse))
  end

  def join_patterns(name, lines)
    lines.map.with_index(0) do |line, i|
      [line, "-#{name}.#{i}"].join
    end
  end

  def tie?
    next_open_cells.empty?
  end

  def find_winner
    [1, 2].each do |number|
      win_pat = "#{number}" * WINCOUNT
      return number if get_board_patterns.any? { |pat| pat.include?(win_pat) }
    end
    false
  end

  def game_over?
    find_winner || tie?
  end

  def any_open_in_col?(col)
    !open_cell_in_col(col).nil?
  end

  def open_cell_in_col(col, cells = @board_data)
    opens = cells.select { |cell| cell.col == col && cell.owner == 0 }
    opens.max_by { |cell| cell.row }
  end

  def next_open_cells(cells = @board_data)
    open_cells = (0...Board::COL_COUNT).map do |col|
      open_cell_in_col(col, cells)
    end
    open_cells.compact
  end

  def fill_cell(col, player, cells = @board_data)
    cell = open_cell_in_col(col, cells)
    cell.owner = player.number
    cell.image = player.image
  end
end
