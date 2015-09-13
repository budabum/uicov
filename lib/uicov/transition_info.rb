#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class TransitionInfo < CoverageInfo
    def self.key(from, to, name)
      [from.to_sym, to.to_sym, name.to_sym]
    end
  end
end
