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
      p 'done'
    end
  end
end

