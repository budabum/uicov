require 'pp'
require 'yaml'

puts "START"

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

class UICoverage
  class Opts
    Patterns = {
      :current_screen => nil,
      :transition => nil,
    }

    Files = {
      :log => nil
    }
  end

  def cov_data
    @cd ||= CoverageData.new
  end

  def init(opts={})
#      if PATTERN_FILE.nil? or !File.exists?(PATTERN_FILE)
#        usage "Patterns file is not provided or it's absent by path: '#{PATTERN_FILE}'"
#      end
    input_log = (Opts::Files[:log] = opts[:log])
    if input_log.nil? or !File.exists?(input_log)
      usage "input log file is not provided or it's absent by path: '#{input_log}'"
    end

    Opts::Patterns.keys.each {|key| Opts::Patterns[key] = opts[key]}

    #d "Using pattern file: #{PATTERN_FILE}"
    #d "Unsing model file: #{MODEL_FILE}"
    d "Parsing log file: #{Opts::Files[:log]}"
  end

  def parse_model
    #TODO: emulation of model reading
    #TODO: can work without model but must be a warning
#    %w[HomeScreen CheckoutScreen OneMoreScreen].each do |name|
#      cov_data.add_screen name
#    end
#    [%w[HomeScreen CheckoutScreen checkout], %w[CheckoutScreen OneMoreScreen one_more],
#     %w[OneMoreScreen CheckoutScreen checkout], %w[HomeScreen OneMoreScreen more]].each do |from, to, name|
#      cov_data.add_transition from, to, name
#    end
  end

  def parse_log
    File.open(Opts::Files[:log]).each do |line|
      case line
      when Opts::Patterns[:current_screen]
        name = $~[1] # $~ - is MatchData of the latest regexp match
        cov_data.hit_screen name
      when Opts::Patterns[:current_screen]
        from, to, name = $~[2], $~[3], $~[1]
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

UICov = UICoverage.new

###########################
#
# E N T R Y   P O I N T
#
###########################

if __FILE__ == $0
  opts = {
    :log => 'logPM.txt',
    :current_screen => /\s+<==\s+([^ ]+)\s+is set as current screen/,
    :transition => /Transition '([^ ]+)'.*from '([^ ]+)'.*to '([^ ]+)'/
  }
  #pp UICov.gather_coverage(opts).screens

  require_relative 'tests/test_uicov.rb'
end

puts "FINISH"

