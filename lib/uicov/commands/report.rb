#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class Report < Command
    OPTIONS = {
      '--report-dir=DIR' => 'Folder to store report files [default is "uicov.report"]',
      '--format=FORMAT ' => 'Report format. One of: html, puml [default is "html"]',
      '--no-transitions' => 'Do not report transitions coverage',
      '--no-actions    ' => 'Do not report actions coverage',
      '--no-checks     ' => 'Do not report checks coverage',
      '--no-elements   ' => 'Do not report elements coverage'
    }
    USAGE_INFO = %Q^[options] file1.uicov [file2.uicov ... fileN.uicov]
      \n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^

    def do_job(args)
      usage 'Missed coverage file', USAGE_INFO if args.empty?
      cov_files = process_args args
      @cd = CovData.load merge_files(cov_files)
      create_per_screen_report
      create_summary_report
      save
    end

    private
    def process_args(args)
      # TODO: process --switches
      # Now only cov files are supported as arguments
      return args
    end

    def merge_files(cov_files)
      # TODO: call merge
      cov_files[0]
    end

    def create_per_screen_report
      @cd.screens.values.each { |s| puts s.report }
    end

    def create_summary_report

    end

    def save

    end
  end
end

