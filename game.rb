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

require 'pry'

class GameWindow < Gosu::Window
  attr_reader :screen_width, :screen_height, :expert_difficulty, :baby_difficulty
  attr_accessor :state

  SCREEN_WIDTH  = 600
  SCREEN_HEIGHT = 550

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
    @baby_difficulty   = 2
    @expert_difficulty = 4
  end

  def create_player(number, difficulty)
    @player1 = get_player(1, @player1_image, difficulty) if number == 1
    @player2 = get_player(2, @player2_image, difficulty) if number == 2
  end

  def get_player(number, image, difficulty)
    if difficulty == 1
      Human.new(number, image, @board_logic, self)
    else
      AI.new(number, image, @board_logic, self, difficulty)
    end
  end

  def human_take_turn(player, col)
    success = player.take_turn(col)
    finish_turn if success  # sucess returns image obj
  end

  def ai_take_turn(player)
    success = player.take_turn
    finish_turn if success
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

  def finish_turn
    @board_logic.game_over? ? @state = :game_over : toggle_turn
  end

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

  def draw_text(x, y, text, font, color)
    font.draw(text, x, y, 1, 1, 1, color)
  end

  def opponent(player)
    player == @player1 ? @player2 : @player1
  end

  def deep_copy(array)
    Marshal.load(Marshal.dump(array))
  end
end

#BEGIN PLAY:
game = GameWindow.new
game.show
