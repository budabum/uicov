#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

$default_screen = :DefaultScreen
$current_screen = /Set ([^ ]+) as current screen/
$transition = /Transition ([^ ]+) from ([^ ]+) to ([^ ]+)/
$action = /Action '([^ ]+)' is done on ([^ ]+)/
$check = /Check '([^ ]+)' is done on ([^ ]+)/
$element = /(?:Click on| Type text .* in) '([^ ]+)' element/

module UICov
  class Gather < Command
    OPTIONS = {
      '--coverage-file=FILE' => 'File to store coverage info [default is "coverage.uicov"]',
      '--pattern-file=FILE' => 'Path to pattern file to override default patterns',
      '--no-transitions' => 'Do not gather transitions coverage',
      '--no-actions    ' => 'Do not gather actions coverage',
      '--no-checks     ' => 'Do not gather checks coverage',
      '--no-elements   ' => 'Do not gather elements coverage'
    }
    USAGE_INFO = %Q^[options] file1.log [file2.log ... fileN.log]
      \n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^

    def do_job(args)
      usage "Missed log file", USAGE_INFO if args.empty?
      @cd = CovData.new
      log_files = process_args args
      parse_logs log_files
      @cd.set_processing_date
      @cd.type = CoverageDataType::COVERAGE
      pp @cd
    end

    private
    def process_args(args)
      # TODO: process --switches
      # Now only log files are supported as arguments
      return args
    end

    def parse_logs(log_files)
      Log.debug "Will parse log files #{log_files}"
      log_files.each { |lf| parse lf }
    end

    def parse(log)
      log_file = File.expand_path log
      File.open(log_file) do |f|
        begin
          current_screen = $default_screen
          expected_current_screen = nil
          last_transition = nil
          cur_screen_data = nil
          while (line = f.readline.chomp)
            case line
              when $current_screen
                name = $~[1] # $~ - is MatchData of the latest regexp match
                current_screen = name
                cur_screen_data = @cd.add_covered_screen name
              when $transition
                name, from, to = $~[1..3]
                unless current_screen == from
                  Log.error %Q^
                    Transition #{name} is done from screen #{from} but current screen is #{current_screen}
                    Found in log #{log_file} at line #{f.lineno}
                  ^
                end
                expected_current_screen = to
                last_transition = name
                cur_screen_data.add_covered_transition name, to
              when $action
                name, screen = $~[1..2]
                unless current_screen == screen
                  Log.error %Q^
                    Action #{name} is done on screen #{screen} but current screen is #{current_screen}
                    Found in log #{log_file} at line #{f.lineno}
                  ^
                end
                cur_screen_data.add_covered_action name
              when $check
                name, screen = $~[1..2]
                unless current_screen == screen
                  Log.error %Q^
                    Check #{name} is done on screen #{screen} but current screen is #{current_screen}
                    Found in log #{log_file} at line #{f.lineno}
                  ^
                end
                cur_screen_data.add_covered_check name
              when $element
                name = $~[1]
                cur_screen_data.add_covered_element name
              else
                #d line
            end
          end
        rescue EOFError => err
          # it's ok
        end
      end
      @cd.add_log_file log_file, File.mtime(log_file).strftime('%F %R:%S.%3N')
    end
  end
end

