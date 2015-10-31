#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class CovData
    attr_accessor :type

    def initialize
      @type = CoverageDataType::UNKNOWN
      @log_files = {}
      @screens = {}
    end

    def set_processing_date(date=Time.now)
      @data_gathered_at = date.strftime('%F %R:%S.%3N')
    end

    def add_covered_screen(name)
      scd = (@screens[name] ||= ScreenData.new name)
      scd.hit
      return scd
    end

    def add_log_file(filename, filedate)
      @log_files[filename] = filedate
    end
  end
end

