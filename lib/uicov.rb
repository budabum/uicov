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

  class Main
    COMMANDS = {
      gather: 'Gather coverage information from log file',
      gentmp: 'Generate coverage template file',
      merge: 'Merge coverage files',
      report: 'Generate coverage report'
    }

    def self.do_command(args)
      if args.empty?
        usage "Command is not specified"
      else
        cmd_name = args[0]
        usage "Wrong command '#{cmd_name}'" unless COMMANDS.keys.include? cmd_name.to_sym
        p UICov.const_get cmd_name.capitalize
      end
    end

    def self.usage(err_msg)
      msg = %Q^
        \rERROR: #{err_msg}\n
        \rUsage:
        \r\t#{$0} command [command_arguments]\n
        \rCommands are:
        #{COMMANDS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
        
        \rTo see command usage run:
        \r\t#{$0} command help\n
        \rFor instance:
        \r\t#{$0} gather help\n
      ^
      puts msg
      exit 1
    end
  end

  class Gather
    def self.do_job
      puts "AAA"
    end
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
end

