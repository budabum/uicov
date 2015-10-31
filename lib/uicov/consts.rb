#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  GEM_TESTS_DIR = "#{GEM_HOME}/test"
  GEM_TESTS_DATA_DIR = "#{GEM_TESTS_DIR}/data"
  GEM_LIB_DIR = "#{GEM_HOME}/lib/uicov"

  require "#{GEM_LIB_DIR}/ruby_patches"
  require "#{GEM_LIB_DIR}/version"
  
  require "#{GEM_LIB_DIR}/commands/command"
  require "#{GEM_LIB_DIR}/main"
  
  require "#{GEM_LIB_DIR}/coverage/types"
  require "#{GEM_LIB_DIR}/coverage/data"
  require "#{GEM_LIB_DIR}/coverage/member_data"
  require "#{GEM_LIB_DIR}/coverage/transition_data"
  require "#{GEM_LIB_DIR}/coverage/action_data"
  require "#{GEM_LIB_DIR}/coverage/check_data"
  require "#{GEM_LIB_DIR}/coverage/element_data"
  require "#{GEM_LIB_DIR}/coverage/screen_data"

  require "#{GEM_LIB_DIR}/opts"
  require "#{GEM_LIB_DIR}/coverage_info"
  require "#{GEM_LIB_DIR}/screen_info"
  require "#{GEM_LIB_DIR}/transition_info"
  require "#{GEM_LIB_DIR}/coverage_data"
  require "#{GEM_LIB_DIR}/ui_coverage"

  Log = Logger.new STDOUT
  Log.level = Logger::DEBUG

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
