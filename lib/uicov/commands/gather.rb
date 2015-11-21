#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

$default_screen = :DefaultScreen

module UICov
  class LogPatterns
    class << self
      attr_accessor :current_screen, :transition, :action, :check, :element

      alias :set_current_screen :current_screen=
      alias :set_transition :transition=
      alias :set_action :action=
      alias :set_check :check=
      alias :set_element :element=
    end
  end

  LogPatterns.current_screen = /Set ([^ ]+) as current screen/
  LogPatterns.transition = /Transition ([^ ]+) from ([^ ]+) to ([^ ]+)/
  LogPatterns.action = /Action '([^ ]+)' is done on screen ([^ ]+)/
  LogPatterns.check = /Check '([^ ]+)' is done on screen ([^ ]+)/
  LogPatterns.element = /(?:Click on| Type text .* in) '([^ ]+)' element/

  class Gather < Command
    DEFAULT_FILENAME = 'coverage.uic'
    OPTIONS = {
      '--coverage-file=FILE' => "File to store coverage info [default is '#{DEFAULT_FILENAME}']",
      '--pattern-file=FILE' => 'Path to pattern file to override default patterns',
      # '--no-transitions' => 'Do not gather transitions coverage',
      # '--no-actions    ' => 'Do not gather actions coverage',
      # '--no-checks     ' => 'Do not gather checks coverage',
      # '--no-elements   ' => 'Do not gather elements coverage'
    }
    USAGE_INFO = %Q^[options] file1.log [file2.log ... fileN.log]
      \n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^

    def initialize
      @coverage_file = DEFAULT_FILENAME
    end

    def do_job(args)
      usage 'Missed log file', USAGE_INFO if args.empty?
      @cd = CovData.new
      log_files = process_args args
      parse_logs log_files
      @cd.set_processing_date
      @cd.type = CoverageDataType::COVERAGE
      @cd.save(@coverage_file)
    end

    private
    def process_args(args)
      coverage_file_option = args.grep(/--coverage-file=.*/)[0]
      if coverage_file_option
        @coverage_file = File.expand_path coverage_file_option.gsub(/.*=(.+)/, '\1')
        args.delete_if { |e| e == coverage_file_option }
      end
      pattern_file_option = args.grep(/--pattern-file=.*/)[0]
      if pattern_file_option
        @pattern_file = File.expand_path pattern_file_option.gsub(/.*=(.+)/, '\1')
        Log.fatal "File #{@pattern_file} does not exist" unless File.exist? @pattern_file
        load @pattern_file
        args.delete_if { |e| e == pattern_file_option }
      end
      return args
    end

    def parse_logs(log_files)
      Log.debug "Will parse log files #{log_files}"
      log_files.each { |lf| parse lf }
    end

    def parse(log)
      log_file = File.expand_path log

      LogPatterns.instance_variables.each { |e| Log.debug "#{e}=#{LogPatterns.instance_variable_get e}" }

      File.open(log_file) do |f|
        begin
          current_screen = $default_screen
          expected_current_screen = nil
          last_transition = nil
          cur_screen_data = nil
          while (line = f.readline.chomp)
            case line
              when LogPatterns.current_screen
                name = $~[1] # $~ - is MatchData of the latest regexp match
                current_screen = name
                cur_screen_data = @cd.add_covered_screen name

              when LogPatterns.transition
                name, from, to = $~[1..3]
                unless current_screen == from
                  Log.error %Q^
                    Transition #{name} is done from screen #{from} but current screen is #{current_screen}
                    Found in log #{log_file} at line #{f.lineno}
                  ^
                end
                if cur_screen_data.nil?
                  Log.error %Q^
                    Wrong model: Transition #{name} is done from unknown screen.
                    Found in log #{log_file} at line #{f.lineno}
                            ^
                else
                  expected_current_screen = to
                  last_transition = name
                  cur_screen_data.add_covered_transition name, to
                end

              when LogPatterns.action
                name, screen = $~[1..2]
                unless current_screen == screen
                  Log.error %Q^
                    Action #{name} is done on screen #{screen} but current screen is #{current_screen}
                    Found in log #{log_file} at line #{f.lineno}
                  ^
                end
                if cur_screen_data.nil?
                  Log.error %Q^
                    Wrong model: Action #{name} is done on unknown screen.
                    Found in log #{log_file} at line #{f.lineno}
                            ^
                else
                  cur_screen_data.add_covered_action name
                end

              when LogPatterns.check
                name, screen = $~[1..2]
                unless current_screen == screen
                  Log.error %Q^
                    Check #{name} is done on screen #{screen} but current screen is #{current_screen}
                    Found in log #{log_file} at line #{f.lineno}
                  ^
                end
                if cur_screen_data.nil?
                  Log.error %Q^
                    Wrong model: Action #{name} is done on unknown screen.
                    Found in log #{log_file} at line #{f.lineno}
                            ^
                else
                  cur_screen_data.add_covered_check name
                end

              when LogPatterns.element
                name = $~[1]
                if cur_screen_data.nil?
                  Log.error %Q^
                    Wrong model: Action #{name} is done on unknown screen.
                    Found in log #{log_file} at line #{f.lineno}
                            ^
                else
                  cur_screen_data.add_covered_element name
                end

              else
                # Log.debug "No match: '#{line}'"
            end
          end
        rescue EOFError => err
          # it's ok
        end
      end
      @cd.add_input_file log_file, File.mtime(log_file).strftime('%F %R:%S.%3N')
    end
  end
end

