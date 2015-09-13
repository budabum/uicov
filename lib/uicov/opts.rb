#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class Opts
    Patterns = {
        :current_screen => nil,
        :transition => nil,
        :transition_from => 2,
        :transition_to => 3,
        :transition_name => 1,
        :model_screen => /^state\s+([^ ]+)$/,
        :model_transition => /^([^ ]+)\s+([-]+\>)\s+([^ ]+)\s+:\s+([^ ]+)$/,
    }

    Files = {
        :log => nil,
        :model => nil,
    }

    Puml = {
        :add_legend => true,
        :missed_class_stereotype => 'Missed',
        :covered_class_stereotype => 'Covered',
    }
  end
end
