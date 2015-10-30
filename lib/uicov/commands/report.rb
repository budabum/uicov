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
    USAGE_INFO = %Q^[options] file1.log [file2.log ... fileN.log]
      \n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^

    def do_job(args)
      usage "Missed log file", USAGE_INFO if args.empty?
      p 'done'
    end
  end
end

