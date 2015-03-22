#!/usr/bin/env ruby
require_relative 'lib/background'
require_relative 'lib/board'
require_relative 'lib/cell'
require_relative 'lib/boardlogic'
require_relative 'lib/boundingbox'
require_relative 'lib/player'
require_relative 'lib/ai'
require_relative 'lib/aipicker'
require_relative 'lib/human'
require_relative 'lib/menu'
require 'gosu'

class GameWindow < Gosu::Window
  attr_reader :screen_width, :screen_height
  attr_accessor :state

  SCREEN_WIDTH  = 600
  SCREEN_HEIGHT = 550
  BABY = 2   # difficulty level
  EXPERT = 5
  TURN_DELAY = 0.5 # seconds delay
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
    @background  = Background.new(self)
    @player1_image = Gosu::Image.new(self, "img/circle_red.png")
    @player2_image = Gosu::Image.new(self, "img/circle_blue.png")
    @board       = Board.new(self)
    @menu        = Menu.new(self, 40, 70, @board)
    @board_logic = BoardLogic.new(self, @board)
    @state       = :menu
    @big_font    = Gosu::Font.new(self, "Futura", SCREEN_HEIGHT / 8)
    @medium_font = Gosu::Font.new(self, "Futura", SCREEN_HEIGHT / 22)
    @small_font  = Gosu::Font.new(self, "Futura", SCREEN_HEIGHT / 30)
    self.caption= "Connect Four!"
  end

  def create_player(number, difficulty)
    @player1 = get_player(1, @player1_image, difficulty) if number == 1
    @player2 = get_player(2, @player2_image, difficulty) if number == 2
  end

  def get_player(number, image, difficulty)
    # This should be changed to not use explicit return statements.
    # use a normal if statement with if difficult == 1 => human else = AI
    return Human.new(number, image, @board_logic, self)    if difficulty == 1
    return AI.new(number, image, @board_logic, self, difficulty) if difficulty != 1
  end

  # these two methods seem very similar, think about the common interface
  # and extract them into one method called take_turn that can be called
  # on a human OR an AI object
  def human_take_turn(player, col)
    success = player.take_turn(col)
    finish_turn if success
  end

  def ai_take_turn(player)
    player.take_turn
    finish_turn
  end

  def button_down(key)
    case key
    when Gosu::MsLeft
      row, col = screen_coord_to_cell(mouse_x, mouse_y)
      if @board.area.click_within?(mouse_x, mouse_y)
        if @state == :player1_turn
          human_take_turn(@player1, col) if @player1.class == Human
        elsif @state == :player2_turn
          human_take_turn(@player2, col) if @player2.class == Human
        end
      end
      if @state == :menu
        @menu.update_selection(mouse_x, mouse_y)
      end
    when Gosu::KbEscape
      close
    when Gosu::KbSpace
      if @state == :game_over
        @board = Board.new(self)
        @background = Background.new(self)
        @board_logic = BoardLogic.new(self, @board)
        @state = :menu
      end
    end
  end

  # the first part of the ternary doesn't need to be in parenthesis
  def finish_turn
    (@board_logic.game_over?) ? @state = :game_over : toggle_turn
  end

  # there might be some way you can use an enum to make this logic
  # cleaner
  def toggle_turn
    if @state == :player1_turn
      @state = :player2_turn
    else
      @state = :player1_turn
    end
  end

  def draw
    @background.draw
    if @state == :menu
      @menu.draw
    else
      @board.draw
      end_game if @state == :game_over
      # I would avoid using sleep, maybe create a timer class that 
      # you can use to create delay logic
      sleep TURN_DELAY
    end
  end

  def update
    if @state == :player1_turn
      ai_take_turn(@player1) if @player1.class == AI
    elsif @state == :player2_turn
      ai_take_turn(@player2) if @player2.class == AI
    end
  end

  def end_game
    if @board_logic.tie?
      text = "Game Over: Tie!"
    else
      number = @board_logic.find_winner
      text = "Player #{number} Wins!"
    end
    reset_text = "(press space bar to reset game)"
    draw_centered_text(450, text, @big_font, 0xffffffff)
    draw_centered_text(520, reset_text, @small_font, Gosu::Color::RED)
  end

  def screen_coord_to_cell(x, y)
    col = ((x - start_x) / @board.cell_dim).to_i
    row = ((y - start_y) / @board.cell_dim).to_i
    [row, col]
  end

  def draw_centered_text(y, text, font, color)
    x = (SCREEN_WIDTH - font.text_width(text)) / 2
    draw_text(x, y, text, font, color)
  end

  def start_x
    @board.left_pad
  end

  def start_y
    @board.top_pad
  end

  def needs_cursor?
    true
  end

  # don't wrap your constants in getters they are already
  # accessible
  def screen_width
    SCREEN_WIDTH
  end

  def screen_height
    SCREEN_HEIGHT
  end

  def draw_text(x, y, text, font, color)
    font.draw(text, x, y, 1, 1, 1, color)
  end

  def opponent(player)
    player == @player1 ? @player2 : @player1
  end

  def self.deep_copy(array)
    Marshal.load(Marshal.dump(array))
  end
end

#BEGIN PLAY:
game = GameWindow.new
game.show
