#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class ActionData
    def initialize(name)
      @name = name
      @hits = 0
    end

    def hit
      @hits += 1
    end
  end
end
