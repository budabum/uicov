#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

require 'logger'
require 'pp'
require 'yaml'

module UICov
  SCRIPT_HOME = File.expand_path(File.dirname(__FILE__))
  TESTS_HOME = "#{SCRIPT_HOME}/../test"
  LIB_HOME = "#{SCRIPT_HOME}/uicov"
  $LOAD_PATH.unshift SCRIPT_HOME

  require "#{LIB_HOME}/ruby_patches"
  require "#{LIB_HOME}/version"

  Log = Logger.new STDOUT
  Log.level = Logger::DEBUG

  def self.gather_coverage(opts={})
    UICoverage.new.gather_coverage(opts)
  end

  def self.usage(err_msg)
    puts "ERROR: #{err_msg}\n\n"
    puts "Usage:\n #{$0} patterns_file log_file\nWhere:\n\tpatterns_file - file with regexp patterns to parse \
your logs\n\tlog_file - your log file from which to get coverage"
    exit 1
  end

  class CoverageInfo
    attr_reader :hits

    def initialize(missed = false)
      @hits = 0
      @missed = missed
    end

    def missed?
      @missed
    end

    def covered?
      0 < hits
    end

    def hit
      @hits = hits.succ
      return self
    end
  end

  ScreenInfo = Class.new(CoverageInfo)

  class TransitionInfo < CoverageInfo
    def self.key(from, to, name)
      [from.to_sym, to.to_sym, name.to_sym]
    end
  end

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

  class UICoverage
    def cov_data
      @cd ||= CoverageData.new
    end

    def init(opts={})
#      if PATTERN_FILE.nil? or !File.exists?(PATTERN_FILE)
#        usage "Patterns file is not provided or it's absent by path: '#{PATTERN_FILE}'"
#      end
      input_log = (Opts::Files[:log] = opts[:log])
      if input_log.nil? or !File.exists?(input_log)
        UICov.usage "Input log file is not provided or it's absent by path: '#{input_log}'"
      end

      model_file = (Opts::Files[:model] = opts[:model])
      if model_file.nil? or !File.exists?(model_file)
        Log.warn "\n\n\tModel file is not provided or it's absent by path: '#{model_file}'" +
                     "\n\tYou won't be able to see uncovered metrics as well as all hits will be" +
                     "reported not as 'covered' but as 'missed in model'\n"
      end

      Opts::Patterns.keys.each {|key| Opts::Patterns[key] = opts[key] unless opts[key].nil?}

      #d "Using pattern file: #{PATTERN_FILE}"
      #d "Unsing model file: #{MODEL_FILE}"
      Log.debug "Parsing log file: #{Opts::Files[:log]}"
      return self
    end

    def parse_model
      model_file = Opts::Files[:model]
      return if model_file.nil?

      Log.debug "Loading model file: #{model_file}"

      File.open(model_file).each do |line|
        case line.chomp
          when /^['@]/ # Do nothing
          when /^\s*$/ # Do nothing
          when Opts::Patterns[:model_screen]
            name = $~[1] # $~ - is MatchData of the latest regexp match
            cov_data.add_screen name
          when Opts::Patterns[:model_transition]
            from, to, name = $~[1], $~[3], $~[4]
            cov_data.add_transition from, to, name
            cov_data.add_screen from
            cov_data.add_screen to
          else
            Log.warn "Unable to parse model line: #{line}"
        end
      end

#    %w[HomeScreen CheckoutScreen OneMoreScreen].each do |name|
#      cov_data.add_screen name
#    end
#    [%w[HomeScreen CheckoutScreen checkout], %w[CheckoutScreen OneMoreScreen one_more],
#     %w[OneMoreScreen CheckoutScreen checkout], %w[HomeScreen OneMoreScreen more]].each do |from, to, name|
#      cov_data.add_transition from, to, name
#    end
      return self
    end

    def parse_log
      transition_indexes = %w[from to name].map{|e| Opts::Patterns["transition_#{e}".to_sym]}
      File.open(Opts::Files[:log]).each do |line|
        case line
          when Opts::Patterns[:current_screen]
            name = $~[1] # $~ - is MatchData of the latest regexp match
            cov_data.hit_screen name
          when Opts::Patterns[:transition]
            from, to, name = transition_indexes.map{|i| $~[i]}
            cov_data.hit_transition from, to, name
          else
            #d line
        end
      end
    end

    def gather_coverage(opts={})
      init opts
      parse_model
      parse_log
      return cov_data
    end
  end # of UICoverage class


  SKIN_PARAMS=%q^
skinparam state {
  FontSize 10
  AttributeFontSize 10

  BackgroundColor #FCFCFC
  BorderColor #C0C0C0
  FontColor #808080
  ArrowColor #C0C0C0
  AttributeFontColor #808080
  ArrowFontColor #808080

  BackgroundColor<<Covered>> #CCFFCC
  BorderColor<<Covered>> #008800
  FontColor<<Covered>> #004400
  AttributeFontColor<<Covered>> #004400

  BackgroundColor<<Missed>> #FFEE88
  BorderColor<<Missed>> #FF8800
  FontColor<<Missed>> #886622
  AttributeFontColor<<Missed>> #886622
}
^

  LEGEND=%q^
state Legend {
    state "Uncovered Screen from Model" as UncoveredScreen
    UncoveredScreen -> CoveredScreen : uncovered_transition {0, 0}
    state "Covered screen from Model" as CoveredScreen<<Covered>>
    CoveredScreen -[#orange]-> MissedScreen : <font color=orange><b>UNKNOWN</b></font> {1, 1} - covered transition missed in Model
    CoveredScreen : <b>covered_action_with_3_calls_from_2_tests</b> {3, 2}
    CoveredScreen : <font color=orange><b>covered_action_missed_in_model</b></font> {1, 1}
    state "Screen missed in Model" as MissedScreen<<Missed>>
    CoveredScreen -[#green]-> CoveredScreen : <font color=green><b>covered_transition_to_self</b></font> {1, 1}
    MissedScreen : uncovered_action {0, 0}
    MissedScreen : <b>covered_action_missed_in_model</b> {1, 1}
    state "Another Covered Screen from Model" as AnotherCoveredScreen<<Covered>>
    MissedScreen -left[#blue]-> AnotherCoveredScreen : <font color=blue><b>DEEP_LINK</b></font> {1, 1}
    AnotherCoveredScreen -[#green]-> CoveredScreen : <font color=green><b>covered_transition</b></font> {1, 1}
    CoveredScreen --> AnotherCoveredScreen : <font color=red>NOT_SET</font> {0, 0} - missed transition name in Model
    AnotherCoveredScreen : uncovered_action {0 ,0}
}
^
end

###########################
# E N T R Y   P O I N T
############################
if __FILE__ == $0
  opts = {
      :log => 'logPM.txt',
      :model => "#{UICov::TESTS_HOME}/model1.puml",
      :current_screen => /\s+<==\s+([^ ]+)\s+is set as current screen/,
      :transition => /Transition '([^ ]+)'.*from '([^ ]+)'.*to '([^ ]+)'/
  }
  puts UICov.gather_coverage(opts).to_puml('log.puml')

  require "#{UICov::TESTS_HOME}/test_uicov.rb"
end
