#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class TransitionData
    def self.get_key(name, to)
      "#{name}(#{to})"
    end

    def initialize(name, to)
      @name = name
      @to = to
      @hits = 0
    end

    def hit
      @hits += 1
    end
  end
end
