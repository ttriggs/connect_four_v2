class Menu
  def initialize(window, x, y, board)
    @x = x
    @y = y
    @board  = board
    @window = window
    @menu_font = Gosu::Font.new(@window, "Futura", @window.height / 15)
    @big_font  = Gosu::Font.new(@window, "Futura", @window.height / 8)
    @bg_image  = Gosu::Image.new(@window, 'img/menu.png')
    @title     = Gosu::Image.new(@window, 'img/title.png')
    @playbox   = BoundingBox.new(90, 400, 120, 50, "start", "PLAY!")
    @p1_difficulty = 1
    @p2_difficulty = 3
    @p1_option_boxes = create_option_boxes(200)
    @p2_option_boxes = create_option_boxes(260)
    @red = Gosu::Color::RED
    @blue = Gosu::Color::BLUE
    @white = 0xffffffff
  end

  def create_option_boxes(y_offset)
    boxes = []
    options = [[160, 90, 1, "Human"], [250, 60, 2, "Easy"], [300, 100, 3,"Medium"],
      [400, 63, 4,"Hard"], [450, 85, 5,"Expert"]]
      options.each_with_index do |set, index|
        left, width, option, name = set
        height = 30
        top = y_offset + (30 * index)
        boxes << BoundingBox.new(left, top, width, height, option, name)
    end
    boxes
  end

  def selection_to_color(selected, current, player_num)
    color = @red if  player_num == 1
    color = @blue if player_num == 2
    selected == current ? color : @white
  end

  def draw
    @bg_image.draw(@x, @y, 0)
    @title.draw(77, 80, 0)
    draw_text(45, 170, "Player1:", @menu_font, @red)
    draw_text(45, 230, "Player2:", @menu_font, @blue)
    @playbox.draw_option(@big_font, @white)

    #draw clickable difficulty boxes
    @p1_option_boxes.each do |box|
      color = selection_to_color(@p1_difficulty, box.number, 1)
      box.draw_option(@menu_font, color)
    end
    @p2_option_boxes.each do |box|
      color = selection_to_color(@p2_difficulty, box.number, 2)
      box.draw_option(@menu_font, color)
    end
  end

  def update_selection(x,y)
    p1_ans = @p1_option_boxes.map {|box| box.number_if_click(x, y)}.compact[0]
    p2_ans = @p2_option_boxes.map {|box| box.number_if_click(x, y)}.compact[0]
    @p1_difficulty = p1_ans if !p1_ans.nil?
    @p2_difficulty = p2_ans if !p2_ans.nil?
    if @playbox.click_within?(x, y)
      @window.create_player(1, @p1_difficulty)
      @window.create_player(2, @p2_difficulty)
      @window.state = :player1_turn
    end
  end

  def draw_text(x, y, text, font, color)
    font.draw(text, x, y, 3, 1, 1, color)
  end
end
