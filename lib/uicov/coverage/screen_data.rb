#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class ScreenData
    attr_reader :elements, :transitions, :actions, :checks
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

    def add_transition(name, to)
      tr_key = TransitionData.get_key(name, to)
      transitions[tr_key] ||= TransitionData.new name, to
    end

    def add_covered_transition(name, to)
      add_transition(name, to).hit
    end

    def add_action(name)
      actions[name] ||= ActionData.new name
    end

    def add_covered_action(name)
      add_action(name).hit
    end

    def add_check(name)
      checks[name] ||= CheckData.new name
    end

    def add_covered_check(name)
      add_check(name).hit
    end

    def add_element(name)
      elements[name] ||= ElementData.new name
    end

    def add_covered_element(name)
      add_element(name).hit
    end

    def report
      %Q^
<h2>Screen: <span>#{@name}</span></h2>
<h3>Coverage summary</h3>
#{report_members_summary 'elements' unless elements.empty?}
#{report_members_summary 'transitions' unless transitions.empty?}
#{report_members_summary 'actions' unless actions.empty?}
#{report_members_summary 'checks' unless checks.empty?}
<h3>Coverage details</h3>
#{report_members 'elements' unless elements.empty?}
#{report_members 'transitions' unless transitions.empty?}
#{report_members 'actions' unless actions.empty?}
#{report_members 'checks' unless checks.empty?}
<hr/>
      ^
    end

    def get_coverage(members_name)
      members = instance_variable_get("@#{members_name}")
      uncovered = members.values.select{|e| e.hits == 0}
      cov = ((members.size.to_f - uncovered.size) / members.size) * 100
      return cov.nan? ? 100.0 : cov.round(2)
    end

    def get_count(members_name, hitted=false)
      members = instance_variable_get("@#{members_name}")
      if hitted
        members.values.keep_if{ |e| 0 < e.hits}.size
      else
        members.size
      end
    end

    private
    def report_members(members_name)
      members = instance_variable_get("@#{members_name}")
      %Q^
<table class='covtable' width='25%'>
<thead><caption>#{members_name.capitalize}:</caption></thead>
<tbody>
<tr><th>Name</th><th>Hits</th></tr>
#{members.values.map{|e| "<tr><td class='namecol'>#{e.display_name}</td><td>#{e.hits}</td></tr>"}.join("\n") }
</tbody>
</table>
<br/>
      ^
    end

    def report_members_summary(members_name)
      coverage = get_coverage members_name
      %Q^
<div>#{members_name.capitalize}: #{coverage}%</div>
      ^
    end
  end
end
