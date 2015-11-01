#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class Report < Command
    OPTIONS = {
      '--report-file=DIR' => 'Folder to store report files [default is "uicov.report.html"]',
      '--format=FORMAT  ' => 'Report format. One of: html, puml [default is "html"]',
      '--no-transitions ' => 'Do not report transitions coverage',
      '--no-actions     ' => 'Do not report actions coverage',
      '--no-checks      ' => 'Do not report checks coverage',
      '--no-elements    ' => 'Do not report elements coverage'
    }
    USAGE_INFO = %Q^[options] file1.uicov [file2.uicov ... fileN.uicov]
      \n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^

    def do_job(args)
      usage 'Missed coverage file', USAGE_INFO if args.empty?
      cov_files = process_args args
      @cd = merged_file(cov_files)
      @html = create_per_screen_report
      @html << create_summary_report
      save
    end

    private
    def process_args(args)
      # TODO: process --switches
      # Now only cov files are supported as arguments
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

    def save(filename='uicov.report.html')
      report_file = File.expand_path filename
      File.open(report_file, 'w'){|f| f.write(@html)}
      Log.info "Result saved into file #{report_file}"
    end
  end
end

