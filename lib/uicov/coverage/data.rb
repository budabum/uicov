#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class CovData
    attr_reader :screens, :input_files
    attr_accessor :type

    def self.load(filename)
      YAML.load_file(filename)
    end

    def initialize(cov_file=nil)
      @type = CoverageDataType::UNKNOWN
      @input_files = {}
      @screens = {}
      load(cov_file) unless cov_file.nil?
    end

    def set_processing_date(date=Time.now)
      @data_gathered_at = date.strftime('%F %R:%S.%3N')
    end

    def add_screen(name)
      @screens[name] ||= ScreenData.new name
    end

    def add_covered_screen(name)
      scd = add_screen name
      scd.hit
      return scd
    end

    def add_input_file(filename, filedate)
      @input_files[filename] = filedate
    end

    def save(filename)
      File.open(filename, 'w') { |f| f.write YAML.dump(self) }
      Log.info "Result saved to '#{File.expand_path(filename)}'"
    end
  end
end

