require_relative 'cells_network'

#
# Builder class to help in creating a cell network with the hope it
# is more readable in the source code, more visual
# 
# A an example:
#
#    net = NetBuilder.build {
#       head '  0 1 2 3 4'
#       line '0 . . . . .'
#       line '1 . . . . .'
#       line '2 . . . . .'
#       line '3 . . # # .'
#       line '4 . . . . .'
#       line '5 . . . . .'
#    }
#
# Use the line and head methods, both expect a string parameter
#   - the header contains numbers separted by spaces, like
#        '  0 1 2 3 4 5 6'
#   - a normal row contains the row number as first element, 
#     followed by a sequence of . or # symbols, like
#        '4 . . # . . # .'
#
# The build is very loose
#  1) it does not check anything (header can contain any character,
#     not only numbers), it is optional and only help to write 
#     even more readable code
#  2) first element of rows is not checked.
#  3) dead cell can be any character, living cells must be #
#
class NetBuilder
  
  @@last_network = nil
  
  # Returns the last network the builder created
  def self.last_network
    @@last_network
  end
  
  def self.build detect_cycles = true, &data
    
    builder = NetBuilder.new
    
    builder.instance_eval(&data)
    
    @@last_network = builder.create(detect_cycles)
    
  end
  
  def initialize
    @rows = []
  end
  
  # Adds the top header definition
  def head h
    @head = h.strip unless @head
  end
  
  # Adds a row to the current network definition
  def line r
    @rows << r.strip
  end
  
  def create detect_cycles

    network = []
    
    width = 0
    height = 0
    
    @rows.each_index do |r|
      
      row = @rows[r].split(' ')
      
      row.shift

      height += 1
      width = row.length if width < row.length
    
      network << []
      
      row.each_index do |c|
        state = row[c]
        network.last << (state == '#' ? LIVE_CELL : DEAD_CELL)
      end
      
    end

    CellsNetwork.new(width, height, detect_cycles, network)
    
  end
  
end
