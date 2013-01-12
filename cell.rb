#
# Cell implementation based on episode #13 "Singleton Object" from Ruby Tapas
# http://devblog.avdi.org/2012/10/22/rubytapas-episode-13-singleton-objects/
#
class << (LIVE_CELL = Object.new)

  def to_s() 'O' end
  def inspect() 'live' end

  def next_generation(x, y, board)
    case board.neighbors(x, y).count(LIVE_CELL)
    when 2..3 then self
    else DEAD_CELL
    end
  end

end

class << (DEAD_CELL = Object.new)

  def to_s() ' ' end
  def inspect() 'dead' end

  def next_generation(x, y, board)
    case board.neighbors(x, y).count(LIVE_CELL)
    when 3 then LIVE_CELL
    else self
    end
  end

end
