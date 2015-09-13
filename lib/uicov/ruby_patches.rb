#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

class Logger
  class Formatter
    MyFormat = "[%s] %s: %s: %s\n"
    def call(severity, time, progname, msg)
      @datetime_format ||= "%H:%M:%S.%5N"
      MyFormat % [format_datetime(time), severity, progname, msg2str(msg)]
    end
  end

  alias :_add :add
  
  def add(severity, message, progname, &blk)
    progname_orig = self.progname
    self.progname = get_caller
    _add(severity, message, progname, &blk)
    self.progname = progname_orig
  end

  private
  def get_caller(idx=2)
    caller[idx].sub(/.*\//, '')
  end

  def add_count(severity) ; end # TODO count warnings and errors
end

