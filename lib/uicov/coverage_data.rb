#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class CoverageData
    def screens
      @screens ||= {}
    end

    def transitions
      @transitions ||= {}
    end

    def str_puml(msg=nil, nl=1)
      @str_puml ||= ""
      unless msg.nil?
        @str_puml << "#{msg}" + "\n" * nl
      end
      return @str_puml
    end

    def add_screen(name)
      screens[name.to_sym] = ScreenInfo.new
    end

    def hit_screen(name)
      name = name.to_sym
      info = screens.fetch(name, ScreenInfo.new(true))
      screens[name] = info.hit
    end

    def add_transition(from, to, name)
      transitions[TransitionInfo.key(from, to, name)] = TransitionInfo.new
    end

    def hit_transition(from, to, name)
      key = TransitionInfo.key(from, to, name)
      info = transitions.fetch(key, TransitionInfo.new(true))
      transitions[key] = info.hit
    end

    def to_puml(file_name=nil)
      str_puml '@startuml'
      str_puml SKIN_PARAMS, 0
      str_puml LEGEND if Opts::Puml[:add_legend]

      screens.each_pair do |screen_name, screen_info|
        stereotype = ''
        stereotype = "<<#{Opts::Puml[:covered_class_stereotype]}>>" if screen_info.covered?
        stereotype = "<<#{Opts::Puml[:missed_class_stereotype]}>>" if screen_info.missed?
        str_puml "state #{screen_name}#{stereotype}"
        mm = transitions.map{|pair| pair if pair[0][0] == screen_name}.compact.each do |transition, transition_info|
          #str_puml transition
          str_puml "#{transition[0]} --> #{transition[1]} : #{transition[2]}"
          #str_puml "#{transition}"
        end

        str_puml ''
      end

      str_puml '@enduml'

      if file_name.nil?
        return str_puml
      else
        Log.unknown "Storing results in file #{File.expand_path(file_name)}"
        File.open(file_name, 'w') {|f| f.write str_puml}
      end
    end
  end
end
