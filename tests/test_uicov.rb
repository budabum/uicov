require_relative 'unittest_addons'

puts "START TESTS"
DEBUG = false

class PropsTests < Test::Unit::TestCase
  COVERAGE_LOG1_FILENAME = "#{File.dirname(__FILE__)}/test_log1.txt"
  CURRENT_SCREEN_PATTERN = /Set ([^ ]+) as current screen/

  def setup
    @missed_screen_names = %w[MissedOneScreen MissedTwoScreen]
    @screen_names = %w[FirstScreen SecondScreen ThirdScreen SecondScreen] # Second screen given twice
    @uniq_screen_names = @screen_names.map(&:to_sym).uniq
    @cd = CoverageData.new
    @uicov = UICoverage.new
  end

  must 'have empty coverage data by default' do
    assert_equal Hash.new, @cd.screens
  end

  must 'add screens to template only once' do
    @screen_names.each {|name| @cd.add_screen name}
    assert_equal @uniq_screen_names, @cd.screens.keys
  end

  must 'add screens to template with 0 hits' do
    @screen_names.each {|name| @cd.add_screen name}
    assert_equal @uniq_screen_names.map{0}, @cd.screens.values.map{|e| e.hits}
  end

  must 'must add screens to template as not missed' do
    @screen_names.each {|name| @cd.add_screen name}
    assert_equal @uniq_screen_names.map{false}, @cd.screens.values.map{|e| e.missed}
  end

  must 'add hits while gathering coverage' do
    cd = @uicov.gather_coverage(
      :log => COVERAGE_LOG1_FILENAME,
      :current_screen => CURRENT_SCREEN_PATTERN
    )
    expected_hits = @uniq_screen_names.inject([]) {|a, _| last = a.empty? ? 0 : a[-1]; a << last + 1}
    assert_equal expected_hits, cd.screens.values.map{|e| e.hits}
  end
end

puts "FINISH TESTS"

