#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class Merge < Command
    OPTIONS = {
      '--merged-file=FILE' => 'File to store merged coverage [default is "merged.uicov"]',
      '--no-transitions' => 'Do not merge transitions coverage',
      '--no-actions    ' => 'Do not merge actions coverage',
      '--no-checks     ' => 'Do not merge checks coverage',
      '--no-elements   ' => 'Do not merge elements coverage'
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

