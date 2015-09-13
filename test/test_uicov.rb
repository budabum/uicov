require_relative 'unittest_addons'

class PropsTests < Test::Unit::TestCase
  COVERAGE_LOG1_FILENAME = "#{File.dirname(__FILE__)}/test_log1.txt"
  MODEL1_FILENAME = "#{File.dirname(__FILE__)}/model1.puml"
  CURRENT_SCREEN_PATTERN = /Set ([^ ]+) as current screen/
  TRANSITION_PATTERN = /Transition ([^ ]+) from ([^ ]+) to ([^ ]+)/

  def setup
    @log_level_orig = Log.level
    Log.level = Logger::FATAL

    @missed_screens = %w[MissedOneScreen MissedTwoScreen]
    @screens = %w[FirstScreen SecondScreen ThirdScreen SecondScreen] # Second screen given twice
    @uniq_screens = @screens.map(&:to_sym).uniq
    @transitions = [
      %w[FirstScreen SecondScreen first_to_second],
      %w[FirstScreen ThirdScreen first_to_third],
      %w[SecondScreen ThirdScreen second_to_third],
      %w[FirstScreen ThirdScreen first_to_third], # Second time here!
      %w[FirstScreen ThirdScreen first_to_third_again] # Another transition
    ]
    @uniq_transitions = @transitions.map{|e| e.map(&:to_sym)}.uniq
    @cd = CoverageData.new
    @uicov = UICoverage.new
  end

  def teardown
    Log.level = @log_level_orig
  end

  must 'have empty coverage data by default' do
    assert_equal Hash.new, @cd.screens
  end

  must 'add screens to template only once' do
    @screens.each {|name| @cd.add_screen name}
    assert_equal @uniq_screens, @cd.screens.keys
  end

  must 'add transitions to template only once' do
    @transitions.each {|from, to, name| @cd.add_transition from, to, name}
    assert_equal @uniq_transitions, @cd.transitions.keys
  end

  must 'add screens to template with 0 hits' do
    @screens.each {|name| @cd.add_screen name}
    assert_equal @uniq_screens.map{0}, @cd.screens.values.map{|e| e.hits}
  end

  must 'add transitions to template with 0 hits' do
    @transitions.each {|from, to, name| @cd.add_transition from, to, name}
    assert_equal @uniq_transitions.map{0}, @cd.transitions.values.map{|e| e.hits}
  end

  must 'must add screens to template as not missed' do
    @screens.each {|name| @cd.add_screen name}
    assert_equal @uniq_screens.map{false}, @cd.screens.values.map{|e| e.missed?}
  end

  must 'must add transitions to template as not missed' do
    @transitions.each {|from, to, name| @cd.add_transition from, to, name}
    assert_equal @uniq_transitions.map{false}, @cd.transitions.values.map{|e| e.missed?}
  end

  ## Kind of functional tests ###

  must 'read the model correctly' do
    uic = @uicov.init(
      :log => COVERAGE_LOG1_FILENAME,
      :model => MODEL1_FILENAME,
    )
    assert_equal Hash.new, uic.cov_data.screens
    assert_equal Hash.new, uic.cov_data.transitions
    uic.parse_model
    expected_screens = [
      :FirstScreen, :SecondScreen, :ThirdScreen, :NoExplicitStateKeywordScreen
    ]
    expected_transitions = [
      TransitionInfo.key(:FirstScreen, :SecondScreen, :first_to_second),
      TransitionInfo.key(:FirstScreen, :NoExplicitStateKeywordScreen, :transition1),
    ]
    assert_equal expected_screens, uic.cov_data.screens.keys
    assert_equal expected_transitions, uic.cov_data.transitions.keys
  end

  must 'add hits while gathering coverage' do
    cd = @uicov.gather_coverage(
      :log => COVERAGE_LOG1_FILENAME,
      :current_screen => CURRENT_SCREEN_PATTERN,
      :transition => TRANSITION_PATTERN
    )
    expected_screen_hits = @uniq_screens.inject([]) {|a, _| last = a.empty? ? 0 : a[-1]; a << last + 1}
    expected_transition_hits = [1,2,3,1]
    assert_equal expected_screen_hits, cd.screens.values.map{|e| e.hits}
    assert_equal expected_transition_hits, cd.transitions.values.map{|e| e.hits}
  end
end

