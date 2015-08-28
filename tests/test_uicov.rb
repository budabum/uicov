require_relative 'unittest_addons'

puts "START TESTS"

class PropsTests < Test::Unit::TestCase
  COVERAGE_LOG1_FILENAME = 'test_log1.txt'
  COVERAGE_LOG1 = File.open(File.dirname(__FILE__)+'/'+COVERAGE_LOG1_FILENAME).readlines.join
  p COVERAGE_LOG1

  def setup
    @screen_names = %w[FirstScreen SecondScreen ThirdScreen SecondScreen] # Second screen given twice
    @uniq_screen_names = @screen_names.map(&:to_sym).uniq
    @coverage_log1 = 
    @cd = CoverageData.new
  end

  must "coverage data is empty by default" do
    assert_equal Hash.new, @cd.screens
  end

  must "screens are added to template only once" do
    @screen_names.each {|name| @cd.add_screen name}
    assert_equal @uniq_screen_names, @cd.screens.keys
  end

  must "screens added to template have 0 hits" do
    @screen_names.each {|name| @cd.add_screen name}
    assert_equal @uniq_screen_names.map{0}, @cd.screens.values.map{|e| e.hits}
  end

  must "screens from log has not 0 hits" do
    @screen_names.each {|name| @cd.add_screen name}
    assert_equal @uniq_screen_names.map{1}, @cd.screens.values.map{|e| e.hits}
  end
end

puts "FINISH TESTS"

