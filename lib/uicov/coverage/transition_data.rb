#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class TransitionData < MemberData
    def self.get_key(name, to)
      "#{name}(#{to})"
    end

    def initialize(name, to)
      @name = name
      @to = to
      @display_name = self.class.get_key @name, @to
      @hits = 0
    end
  end
end
