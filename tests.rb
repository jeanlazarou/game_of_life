require 'test/unit'

require_relative 'net_builder'

class NetworkBuilderTests < Test::Unit::TestCase

  def test_visual_creation

    net = NetBuilder.build {
       head '  0 1 2 3 4 5 6 7 8 9'
       line '0 . . . . . . . . . .'
       line '1 . . . . . . . . . .'
       line '2 . . . . . . . . . .'
       line '3 . . # # . . . . . .'
       line '4 . . . . . . # . . .'
       line '5 . . . . . # . . . .'
       line '6 . . . . # . . . . .'
       line '7 . . . . . . . . . .'
       line '8 . . . . . . . . . .'
       line '9 . . . . . . . . . #'
    }
    
    assert_equal 10, net.width
    assert_equal 10, net.height
  
    assert_equal LIVE_CELL, net.cell(2, 3)
    assert_equal LIVE_CELL, net.cell(3, 3)
    assert_equal LIVE_CELL, net.cell(4, 6)
    assert_equal LIVE_CELL, net.cell(5, 5)
    assert_equal LIVE_CELL, net.cell(4, 6)
    assert_equal LIVE_CELL, net.cell(9, 9)
    
    assert_equal  6, net.cells.count(LIVE_CELL)
    assert_equal 94, net.cells.count(DEAD_CELL)
    
  end
  
  def test_not_square

    net = NetBuilder.build {
       head '  0 1 2 3 4'
       line '0 . . . . .'
       line '1 . . . . .'
       line '2 . . . . .'
       line '3 . . # # .'
       line '4 . . . . .'
       line '5 . . . . .'
    }
    
    assert_equal 5, net.width
    assert_equal 6, net.height
  

  end

end

class CellsNetworkTests < Test::Unit::TestCase

  def test_to_s

    net = NetBuilder.build {
       head '  0 1 2 3'
       line '0 . . . .'
       line '1 . # # .'
       line '2 . # . .'
       line '3 . . . #'
    }

    expected = "        " + "\n" +
               "  O O   " + "\n" +
               "  O     " + "\n" +
               "      O " + "\n"
    
    assert_equal expected, net.to_s

  end
    
  def test_neighbors

    net = NetBuilder.build {
       head '  0 1 2 3'
       line '0 . . . .'
       line '1 . # # .'
       line '2 . # . .'
       line '3 . . . #'
    }

    neighbors = net.neighbors(0, 0)
    
    assert_equal 8, neighbors.size
    assert_equal 6, neighbors.count(DEAD_CELL)
    assert_equal 2, neighbors.count(LIVE_CELL)

    neighbors = net.neighbors(1, 0)
    
    assert_equal 8, neighbors.size
    assert_equal 6, neighbors.count(DEAD_CELL)
    assert_equal 2, neighbors.count(LIVE_CELL)

    neighbors = net.neighbors(2, 1)
    
    assert_equal 8, neighbors.size
    assert_equal 6, neighbors.count(DEAD_CELL)
    assert_equal 2, neighbors.count(LIVE_CELL)

    neighbors = net.neighbors(2, 2)
    
    assert_equal 8, neighbors.size
    assert_equal 4, neighbors.count(DEAD_CELL)
    assert_equal 4, neighbors.count(LIVE_CELL)

  end
  
end

class TwoGenerationsTest  < Test::Unit::TestCase

  def test_end_of_life_cycle
    
    net = NetBuilder.build {
      head '     0 1 2 3 4 5 6 7 8 9'  #        0 1 2 3 4 5 6 7 8 9         0 1 2 3 4 5 6 7 8 9
      line '   0 . . . . . . . . . .'  #      0 . . . . . . . . . .       0 . . . . . . . . . .
      line '   1 . . . . . . . . . .'  #      1 . . . . . . . . . .       1 . . . . . . . . . .
      line '   2 . . . . . . . . . .'  #      2 . . . . . . . . . .       2 . . . . . . . . . .
      line '   3 . . # # . . . . . .'  #      3 . . . . . . . . . .       3 . . . . . . . . . .
      line '   4 . . . . . . # . . .'  # -->  4 . . . . . . . . . .  -->  4 . . . . . . . . . .
      line '   5 . . . . . # . . . .'  #      5 . . . . . # . . . .       5 . . . . . . . . . .
      line '   6 . . . . # . . . . .'  #      6 . . . . . . . . . .       6 . . . . . . . . . .
      line '   7 . . . . . . . . . .'  #      7 . . . . . . . . . .       7 . . . . . . . . . .
      line '   8 . . . . . . . . . .'  #      8 . . . . . . . . . .       8 . . . . . . . . . .
      line '   9 . . . . . . . . . #'  #      9 . . . . . . . . . .       9 . . . . . . . . . .
    }
    
    net.next_generation
    assert_equal LIVE_CELL, net.cell(5, 5)
    assert_equal 99, net.cells.count(DEAD_CELL)
    
    net.next_generation
    assert_equal 100, net.cells.count(DEAD_CELL)
    
  end

end 

class NextGenerationTests < Test::Unit::TestCase

  def setup
    
    @net = NetBuilder.build {
      head '  0 1 2 3'  #         0 1 2 3          0 1 2 3         0 1 2 3
      line '0 . . . .'  #       0 . . # .        0 . . . .       0 . . # .
      line '1 . # # #'  #  -->  1 . . # .  -->   1 . # # #  -->  1 . . # .
      line '2 . . . .'  #       2 . . # .        2 . . . .       2 . . # .
      line '3 . . . .'  #       3 . . . .        3 . . . .       3 . . . .
    }
    
  end
    
  def test_one_generation_tick
  
    @net.next_generation
    
    assert_equal LIVE_CELL, @net.cell(2, 0)
    assert_equal LIVE_CELL, @net.cell(2, 1)
    assert_equal LIVE_CELL, @net.cell(2, 2)
    assert_equal 13, @net.cells.count(DEAD_CELL)
    
  end
    
  def test_two_generation_ticks
  
    @net.next_generation
    @net.next_generation
    
    assert_equal LIVE_CELL, @net.cell(1, 1)
    assert_equal LIVE_CELL, @net.cell(2, 1)
    assert_equal LIVE_CELL, @net.cell(3, 1)
    assert_equal 13, @net.cells.count(DEAD_CELL)
    
  end
    
  def test_cycle_detection
    
    serie = [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]  #    0 1 2 3
    @net.randomizer = proc do                                 #  0 # . . .
      serie.shift                                             #  1 # . . .
    end                                                       #  2 # . . .
                                                              #  3 # . . .
  
    3.times { @net.next_generation }
    
    assert_equal LIVE_CELL, @net.cell(0, 0)
    assert_equal LIVE_CELL, @net.cell(0, 1)
    assert_equal LIVE_CELL, @net.cell(0, 2)
    assert_equal LIVE_CELL, @net.cell(0, 3)
    assert_equal 12, @net.cells.count(DEAD_CELL)
    
  end
  
end
