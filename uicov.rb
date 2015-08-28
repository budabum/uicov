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
  attr_reader :hits, :missed

  def initialize(missed = false)
    @hits = 0
    @missed = missed
  end

  def hit
    @hits = hits.succ
    return self
  end
end

class TransitionInfo
  attr_reader :hits, :missed

  def self.key(from, to, name)
    [from.to_sym, to.to_sym, name.to_sym]
  end

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
  def screens
    @screens ||= {}
  end

  def transitions
    @transitions ||= {}
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
end

CD = CoverageData.new

NEW_SCREEN_IS_SET_PATTERN = /1\s+<==\s+([^ ]+)\s+is set as current screen/
TRANSITION_IS_DONE_PATTERN = /Transition '([^ ]+)'.*from '([^ ]+)'.*to '([^ ]+)'/

class UICov
  class << self
    def init
      if PATTERN_FILE.nil? or !File.exists?(PATTERN_FILE)
        usage "Patterns file is not provided or it's absent by path: '#{PATTERN_FILE}'"
      end

      if INPUT_LOG.nil? or !File.exists?(INPUT_LOG)
        usage "Input log file is not provided or it's absent by path: '#{INPUT_LOG}'"
      end

      d "Using pattern file: #{PATTERN_FILE}"
      d "Unsing model file: #{MODEL_FILE}"
      d "Parsing log file: #{INPUT_LOG}"
    end

    def parse_model
      #TODO: emulation of model reading
      #TODO: can work without model but must be a warning
      %w[HomeScreen CheckoutScreen OneMoreScreen].each do |name|
        CD.add_screen name
      end
      [%w[HomeScreen CheckoutScreen checkout], %w[CheckoutScreen OneMoreScreen one_more],
       %w[OneMoreScreen CheckoutScreen checkout], %w[HomeScreen OneMoreScreen more]].each do |from, to, name|
        CD.add_transition from, to, name
      end
    end

    def parse_log
      File.open(INPUT_LOG).each do |line|
        case line
        when NEW_SCREEN_IS_SET_PATTERN
          name = $~[1]
          CD.hit_screen name
        when TRANSITION_IS_DONE_PATTERN
          from, to, name = $~[2], $~[3], $~[1]
          CD.hit_transition from, to, name
        else
      #    d "--"
        end
      end
    end

    def gather
      init
      parse_model
      parse_log
    end

  end # of class << self
end # of class

###########################
#
# E N T R Y   P O I N T
#
###########################

if __FILE__ == $0
  require_relative 'tests/test_uicov.rb'
end

puts "FINISH"

