require 'digest'

require_relative 'cell'

class CellsNetwork

  HISTORY_SIZE = 4
  
  attr_reader :width, :height
  attr_accessor :randomizer # should return 1 for a live cell, anything else for a dead cell
  
  def initialize width, height, cycle_detection = true, seed_network = nil
  
    @randomizer = proc {rand(2)}
    
    @cycle_detection_enabled = cycle_detection
    
    @width = width
    @height = height

    if seed_network
      self.network = seed_network
    else
      generate_network
    end
    
    reset_history
    
  end
    
  def generate_network
  
    new_network = []

    @height.times do
    
      new_network << []
      
      @width.times do
        new_network.last << (@randomizer.call == 1 ? LIVE_CELL : DEAD_CELL)
      end
      
    end
    
    reset_history
    
    self.network = new_network
    
  end
  
  def to_s
    @buffer  
  end

  def cycles?
    @history.any? {|sha| sha == @current_sha}
  end
  
  def next_generation

    if @cycle_detection_enabled and cycles?
      generate_network
      return
    end
    
    @history << @current_sha
    @history.shift if @history.length > HISTORY_SIZE
    
    new_network = []
    
    @height.times do |y|
    
      new_network << []
      
      @width.times do |x|
        new_value = @network[y][x].next_generation(x, y, self)
        new_network.last[x] = new_value
      end
      
    end
    
    self.network = new_network
    
  end
  
  def neighbors x, y
    
    cells = []
    
    cells << @network[y][x-1]
    cells << @network[y][x+1]
    
    cells << @network[y-1][x-1]
    cells << @network[y-1][x]
    cells << @network[y-1][x+1]
    
    y = -1 if y + 1 == @height
    
    cells << @network[y+1][x-1]
    cells << @network[y+1][x]
    cells << @network[y+1][x+1]
    
    cells
    
  end

  def cells
    @network.flatten
  end
  
  def cell x, y
    @network[y][x]
  end
  
  private
  
  def network= new_network
    
    @network = new_network
    
    @buffer = ''
    
    @network.each do |row|
      
      row.each do |cell|
        @buffer << cell.to_s
        @buffer << ' '
      end
      
      @buffer << "\n"
      
    end
    
    @current_sha = Digest::SHA1.hexdigest(@buffer)
    
  end
  
  def reset_history
    @history = []
  end
  
end
