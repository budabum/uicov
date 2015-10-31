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
    USAGE_INFO = %Q^[options] template.uicov file1.uicov [file2.uicov ... fileN.uicov]
      \n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^

    def do_job(args)
      usage 'Missed coverage file', USAGE_INFO if args.empty?
      p 'done'
    end
  end
end

