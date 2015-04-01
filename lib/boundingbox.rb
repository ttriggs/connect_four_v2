class BoundingBox
  attr_reader :left, :right, :top, :bottom, :width, :height, :number, :name
  def initialize(left, top, width, height, number="", name="")
    @left = left
    @top = top
    @width = width
    @height = height
    @number = number
    @right = @left + @width
    @bottom = @top + @height
    @name = name
  end

  def click_within?(x, y)
    x.between?(left, right) && y.between?(top, bottom)
  end

  def number_if_click(x, y)
    number if click_within?(x, y)
  end

  def draw_option(font, color)
    font.draw(name, left, top, 3, 1, 1, color)
  end
end
