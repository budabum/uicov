#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class CoverageInfo
    attr_reader :hits

    def initialize(missed = false)
      @hits = 0
      @missed = missed
    end

    def missed?
      @missed
    end

    def covered?
      0 < hits
    end

    def hit
      @hits = hits.succ
      return self
    end
  end
end
