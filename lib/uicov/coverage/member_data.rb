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

    def hit
      @hits += 1
    end
  end
end

