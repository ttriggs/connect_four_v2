Language: ruby 2.0.0p576 (2014-09-19) [x86_64-darwin14.0.0]
Author: Tyler Triggs
Date: 20150102
About:
This is an ASCII version of Connect Four where you can play against an AI with 4 difficulty levels. Optionally, you can play against a friend or simulate matches between two AIs.
Comments and collaborations welcome!

Explanation of classes:
Player: The Player class houses data that both human and AI players use: player number (1 or 2), player token ("x" or "o").

Human (Player subclass): The Human class houses the human-specific version of method "take_turn" which prompts the user to pick an open column.  

AI (Player subclass): In addition to inheriting standard Player data, the AI class houses a difficulty setting and a @rank_guide variable and @col_rank variable. The majority of the code for the AI "take_turn" method is within the Board class. For the AI, picking a column involves simulating future board states and weighing the most option that brings the AI closer to winning and further from losing. To do this, it will simulate each of its possible moves and weigh how helpful they are, and then simulate all of its opponents possible next moves and re-weigh each option. To keep track of board states of interest (am I about to win/lose?), I have the AI stash away a cheat sheet arrays "pos_pats" (has patterns it can win from) "neg_pats" (houses patterns that its opponent may win from without intervention). For simplicity's sake, I didn't make the AI perform an exhaustive analysis. Within its turn, the AI will only check each column for itself, start fresh, then check for its opponent's moves (as opposed to simulating an opponent's move after it simulates its own move etc).

Board: The Board class keeps data for the playboard other display elements (ASCII art "connect four"). 
  A two-dimensional array houses the board cell data (@board_cells). Each element of the array containing positional info and if it is empty, or filled by one of the two players. This class is also responsible for checking for a winner as well as housing the code that makes column choices for the AI. To check the board for win patterns, I decided to first extract the "filled" status from @board_cells and store this in @board_patterns - appending to @board_patterns array each possible win direction (column, row, left or right diagonals) in a string form, including where on the board the pattern is found: "111000-col.1". The differing AI difficulties were created primarily by altering how far ahead in moves the AI will look before choosing a column (with one exception: the Baby difficulty level chooses a random open column). 

Game: The Game class is used to house data and methods to set the game in motion as well as keep track of whose turn it is (determine if player should be human or AI, set up a turn queue for the two players, and to house the "deep_copy_array" code used by Player and Board classes). 

Other notes: This is my first "big" project using an object-oriented language, so my guess is that I probably approached some problems in strange ways. Suggestions/Fixes/Comments welcome!
