#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class CheckData
    def initialize(name)
      @name = name
      @hits = 0
    end

    def hit
      @hits += 1
    end
  end
end
