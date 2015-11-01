#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class TransitionData < MemberData
    def self.get_key(transition_name, to)
      "#{transition_name}(#{to})"
    end

    def initialize(transition_name, to)
      @name = transition_name
      @to = to
      @display_name = self.class.get_key @name, @to
      @hits = 0
    end
  end
end
