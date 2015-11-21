#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  def self.patterns_override(target, &blk)
    case target
      when :log
        LogPatterns.class_exec &blk
      else
        Log.fatal "Unknown target '#{target}' in pattern file '#{caller[0]}'"
    end
  end

  class Main
    COMMANDS = {
      gentpl: 'Generate coverage template file',
      gather: 'Gather coverage information from log file',
      report: 'Generate coverage report',
      merge: 'Merge coverage files',
    }

    COMMANDS.keys.each { |k| require_relative "commands/#{k}" }

    def self.do_command(args)
      if args.empty?
        usage "Command is not specified"
      else
        cmd_name = args[0]
        usage "Wrong command '#{cmd_name}'" unless COMMANDS.keys.include? cmd_name.to_sym
        class_type = UICov.const_get cmd_name.capitalize
        class_type.new.do_job args[1..-1]
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
        \r\t#{$0} command\n
        \rFor instance:
        \r\t#{$0} gather\n
      ^
      Log.fatal msg
    end
  end
end

