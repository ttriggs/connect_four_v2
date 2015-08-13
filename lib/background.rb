class Background
  def initialize(window)
    @window = window
    bg = ['bg1.png', 'bg2.png', 'bg3.png'].sample
    @bg_image = Gosu::Image.new("img/backgrounds/#{bg}")
  end

  def draw
    @bg_image.draw(0, 0, 0)
  end
end
