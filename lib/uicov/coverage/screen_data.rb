#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class ScreenData
    def initialize(name)
      @name = name
      @hits = 0
      @elements = {}
      @transitions = {}
      @actions = {}
      @checks = {}
    end

    def hit
      @hits += 1
    end

    def add_covered_transition(name, to)
      tr_key = TransitionData.get_key(name, to)
      trd = (@transitions[tr_key] ||= TransitionData.new name, to)
      trd.hit
    end

    def add_covered_action(name)
      ad = (@actions[name] ||= ActionData.new name)
      ad.hit
    end

    def add_covered_check(name)
      ad = (@checks[name] ||= CheckData.new name)
      ad.hit
    end

    def add_covered_element(name)
      ad = (@elements[name] ||= ElementData.new name)
      ad.hit
    end
  end
end
