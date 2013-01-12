require 'curses'
require 'monitor'
require 'optparse'

require_relative 'cells_network'

class GameofLifeContoller
  
  def initialize cells_network, view, rate
    
    @rate = rate

    @cells_network = cells_network
  
    @view = view
    @lock = Monitor.new
    
  end
  
  def start

    @view.start @cells_network

    launch_timer
      
    action = nil
    
    loop do

      @lock.synchronize do
        
        process_action action
        
      end
      
      action = @view.input_action
      
      sleep 0.5
      
    end
    
    
  end
  
  def process_action action
    
    case action
    
      when :new
        @lock.synchronize do
          @cells_network.generate_network
          @view.refresh
        end
      when :exit
        @view.quit
        
    end
  
  end
  
  def launch_timer
    
    Thread.new do

      loop do
        
        @lock.synchronize do
          @cells_network.next_generation
          @view.refresh
        end
      
        sleep @rate
        
      end
      
    end
    
  end

end

class GameOfLifeCursesUI
  
  def refresh
    
    @main_win.close
    
    @main_win = nil
    
    start @cells_network
    
    @main_win.refresh
    
  end
  
  def start cells_network
    
    @cells_network = cells_network
    
    unless @init_done
    
      Curses::init_screen
      Curses::raw
      Curses::noecho
      Curses::curs_set 0

      trap(0) { Curses::echo }
      
      @init_done = true
      
    end

    @board_width = @cells_network.width
    @board_height = @cells_network.height

    @main_win = Curses::Window.new(@board_height + 10, @board_width * 2 + 5, 0, 0)
    
    @main_win.nodelay = true

    @main_win.setpos(0,0)
    @main_win.addstr(cells_network.to_s)
    
    @main_win.setpos(cells_network.height + 2, 2)
    @main_win.addstr("Keyboard commands:
    e            to exit
    n            to start a new network
    ")
    
  end
  
  def quit
    Curses::echo
    exit
  end
  
  def input_action

    c = @main_win.getch
    
    if c == 'n'
      :new
    elsif c == 'e'
      :exit
    end
    
  end
  
end

if $0 == __FILE__

  rate = 2
  asked_width = 20
  asked_height = 20
  start_up_file = nil
  cycle_detection = true

  parser = OptionParser.new do |opts|
    
    opts.banner = "Usage: #{$0} [options]"

    opts.separator ""
    opts.separator "Where options include:"
    
    opts.on("-w", "--width w", "Width for the board width (defaults to #{asked_width})") do |w|
      asked_width = w.to_i
    end
    opts.on("-h", "--height h", "Height for the board height (defaults to #{asked_height})") do |h|
      asked_height = h.to_i
    end

    opts.on("-r", "--rate sec", "Next generation rate (in seconds, can be a float)", "(defaults to #{rate})") do |r|
      rate = r.to_f.round(2)
      rate = 0.2 if rate < 0.02
    end

    opts.on("-n", "--no-cycle-detection", "Disable cycle detection and network restart", "(defaults to 'enabled')") do
      cycle_detection = false
    end
    
    opts.on("-s", "--shape file", "A file containing a network shape as startup network", "Using the network builder.") do |file|
      start_up_file = file
    end
    
    opts.on_tail("-?", "--help", "Show this message") do
      puts opts
      exit
    end
    
  end

  startup_failure = proc do |msg|
    
    $stderr.puts msg
    $stderr.puts
    $stderr.puts parser
      
    exit 1
    
  end
  
  begin
    
    tail = parser.parse!

    unless tail.empty?
      
      startup_failure.call "Invalid options '#{tail.join(' ')}'"
      
    end
    
  rescue OptionParser::ParseError => e
    
    startup_failure.call e.message.capitalize
    
  end
  
  if start_up_file and !File.exist?(start_up_file)
    
    startup_failure.call "Shape file not found '#{start_up_file}'"
    
  end

  if start_up_file
  
    require_relative 'net_builder'
    
    if !load(start_up_file) or NetBuilder.last_network.nil?
      startup_failure.call "Invalid shape file '#{start_up_file}'"
    end
    
    network = NetBuilder.last_network
    
  else
    
    network = CellsNetwork.new(asked_width, asked_height, cycle_detection)
    
  end
  
  ui = GameOfLifeCursesUI.new

  controller = GameofLifeContoller.new(network, ui, rate)

  controller.start

end
