#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

require 'logger'
require 'pp'
require 'yaml'

module UICov
  GEM_HOME = File.expand_path("#{File.dirname(__FILE__)}/..")
  $LOAD_PATH.unshift GEM_HOME
  require 'lib/uicov/consts'

  def self.usage(err_msg)
    puts "ERROR: #{err_msg}\n\n"
    puts "Usage:\n #{$0} patterns_file log_file\nWhere:\n\tpatterns_file - file with regexp patterns to parse \
your logs\n\tlog_file - your log file from which to get coverage"
    exit 1
  end

  def self.gather_coverage(opts={})
    UICoverage.new.gather_coverage(opts)
  end

end
###########################
# E N T R Y   P O I N T
############################
if __FILE__ == $0
  opts = {
      :log => 'logPM.txt',
      :model => "#{UICov::GEM_TESTS_DATA_DIR}/model1.puml",
      :current_screen => /\s+<==\s+([^ ]+)\s+is set as current screen/,
      :transition => /Transition '([^ ]+)'.*from '([^ ]+)'.*to '([^ ]+)'/
  }
  puts UICov.gather_coverage(opts).to_puml('log.puml')

  require "#{UICov::GEM_TESTS_DIR}/test_uicov.rb"
end
