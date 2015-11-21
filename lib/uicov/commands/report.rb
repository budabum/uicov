#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class Report < Command
    DEFAULT_FILENAME = 'uicov.report.html'
    OPTIONS = {
      '--report-file=FILE' => "File to store report [default is '#{DEFAULT_FILENAME}']",
      # '--format=FORMAT  ' => 'Report format. One of: html, puml [default is "html"]',
      # '--no-transitions ' => 'Do not report transitions coverage',
      # '--no-actions     ' => 'Do not report actions coverage',
      # '--no-checks      ' => 'Do not report checks coverage',
      # '--no-elements    ' => 'Do not report elements coverage'
    }
    USAGE_INFO = %Q^[options] file1.uic [file2.uic ... fileN.uic]
      \n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^

    def initialize
      @report_file = DEFAULT_FILENAME
    end

    def do_job(args)
      usage 'Missed coverage file', USAGE_INFO if args.empty?
      cov_files = process_args args
      @cd = merged_file(cov_files)
      @html = create_per_screen_report
      @html << create_summary_report
      save @report_file
    end

    private
    def process_args(args)
      report_file_option = args.grep(/--report-file=.*/)[0]
      if report_file_option
        @report_file = File.expand_path report_file_option.gsub(/.*=(.+)/, '\1')
        args.delete_if { |e| e == report_file_option }
      end
      return args
    end

    def merged_file(cov_files)
      cov_files.size > 1 ? Merge.new.merge(cov_files) : CovData.load(cov_files.first)
    end

    def create_per_screen_report
      @cd.screens.values.map{ |s| s.report }.join("\n")
    end

    def create_summary_report
      ''
    end

    def save(filename)
      report_file = File.expand_path filename
      File.open(report_file, 'w'){|f| f.write(@html)}
      Log.info "Result saved into file #{report_file}"
    end
  end
end

