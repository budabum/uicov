#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

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
      @cd.add_log_file log_file, File.mtime(log_file).strftime('%F %R:%S.%3N')
    end
  end
end

