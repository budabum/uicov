#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class Gentmp < Command
    DEFAULT_FILENAME = 'template.uicov'
    OPTIONS = {
      '--template-file=FILE' => "File to store coverage template [default is '#{DEFAULT_FILENAME}']'",
      '--puml=DIR      ' => 'Folder where Plant UML model files are',
      '--no-transitions' => 'Do not include transitions templates',
      '--no-actions    ' => 'Do not include actions templates',
      '--no-checks     ' => 'Do not include checks templates',
      '--no-elements   ' => 'Do not include elements templates'
    }
    USAGE_INFO = %Q^[options] model-file1.puml [model-file2.puml ... model-fileN.puml]
      or
      \r\t#{COMMAND_PREFIX} [options] --puml=DIR      \n\n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^

    def do_job(args)
      usage 'Missed model file', USAGE_INFO if args.empty?
      p 'done'
    end
  end
end

