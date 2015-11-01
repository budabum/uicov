#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class MemberData
    attr_reader :display_name, :hits
    def initialize(name)
      @display_name = name
      @hits = 0
    end

    def hit(increment=1)
      @hits += increment
    end
  end
end

