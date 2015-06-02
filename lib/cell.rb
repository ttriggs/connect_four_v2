class Cell
  attr_reader :col, :row
  attr_accessor :owner, :image
  def initialize(col, row, owner, image)
    @col = col
    @row = row
    @owner = owner
    @image = image
  end

  def any?
    true
  end

  def empty?
    false
  end

  def self.for_animation(cell, owner, image)
    new(cell.col, cell.row, owner, image)
  end
end
