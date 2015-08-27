require 'pp'
require 'yaml'

puts "START"

#PATTERN_FILE = ARGV[0]
#INPUT_LOG = ARGV[1]
PATTERN_FILE = $0
MODEL_FILE = nil
INPUT_LOG = 'logPM.txt'

###########################
#
# M E T H O D S
#
###########################
def usage(err_msg)
  puts "ERROR: #{err_msg}\n\n"
  puts "Usage:\n #{$0} patterns_file log_file\nWhere:\n\tpatterns_file - file with regexp patterns to parse \
your logs\n\tlog_file - your log file from which to get coverage"
  exit 1
end

DEBUG = ENV['DEBUG'] != "false" || true
def d(msg)
  puts "DEBUG: #{msg}" if DEBUG
end

###########################
#
# C L A S S E S
#
###########################
class ScreenInfo
  attr_reader :hits, :name, :missed

  def initialize(missed = false)
    @hits = 0
    @missed = missed
  end

  def hit
    @hits = hits.succ
    return self
  end
end

class CoverageData
  class << self
    def screens
      @screens ||= {}
    end

    def add_screen(name)
      screens[name] = ScreenInfo.new
    end

    def hit_screen(name)
      screen_info = screens.fetch(name, ScreenInfo.new(true))
      screens[name] = screen_info.hit
    end
  end
end

CD = CoverageData

#CoverageData.add_screen("A")
#CoverageData.add_screen("B")
#CoverageData.add_screen("A")

def parse_model
  %w[HomeScreen CheckoutScreen OneMoreScreen].each do |name|
    CD.add_screen name
  end
end


###########################
#
# E N T R Y   P O I N T
#
###########################

if PATTERN_FILE.nil? or !File.exists?(PATTERN_FILE)
  usage "Patterns file is not provided or it's absent by path: '#{PATTERN_FILE}'"
end

if INPUT_LOG.nil? or !File.exists?(INPUT_LOG)
  usage "Input log file is not provided or it's absent by path: '#{INPUT_LOG}'"
end

d "Using pattern file: #{PATTERN_FILE}"
d "Unsing model file: #{MODEL_FILE}"
d "Parsing log file: #{INPUT_LOG}"

NEW_SCREEN_IS_SET_PATTERN = /\s+<==\s+([^ ]+)\s+is set as current screen/

parse_model #note that without the model only covered data is added but there is no info bout uncovered data

File.open(INPUT_LOG).each do |line|
  case line
  when NEW_SCREEN_IS_SET_PATTERN
    screen_name = $~[1]
    CD.hit_screen screen_name
  else
#    d "--"
  end
end

puts CD.screens.to_yaml

puts "FINISH"

