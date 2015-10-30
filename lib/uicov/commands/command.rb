#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class Command
    COMMAND_PREFIX = "#{$0} #{ARGV[0]}"
    def do_job(args)
      Log.fatal "Method #{__method__} is not overridden in class #{self.class.name}"
    end

    def usage(err_msg='', cmd_usage_info='')
      msg = %Q^
        \rERROR: #{err_msg}\n
        \rUsage:
        \r\t#{COMMAND_PREFIX} #{cmd_usage_info} 
      ^

      Log.fatal msg
    end
  end
end

