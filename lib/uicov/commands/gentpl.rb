#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class ModelPatterns
    class << self
      attr_accessor :current_screen_start, :current_screen_end, :transition, :action, :check, :element
    end
  end

  ModelPatterns.current_screen_start = /\s*class\s+([^ ]+)\{\s*/
  ModelPatterns.current_screen_end = /\s*}\s*/
  ModelPatterns.transition = /\s*Transition\s+([^ ]+)\s*\((\s*[^ ]+\s*)\)\s*/
  ModelPatterns.action = /\s*Action\s+([^ ]+)\s*/
  ModelPatterns.check = /\s*Check\s+([^ ]+)\s*/
  ModelPatterns.element = /\s*Element\s+([^ ]+)\s*/

  class Gentpl < Command
    DEFAULT_FILENAME = 'template.uic'
    OPTIONS = {
      '--template-file=FILE' => "File to store coverage template [default is '#{DEFAULT_FILENAME}']",
      # '--puml=DIR      ' => 'Folder where Plant UML model files are',
      # '--no-transitions' => 'Do not include transitions templates',
      # '--no-actions    ' => 'Do not include actions templates',
      # '--no-checks     ' => 'Do not include checks templates',
      # '--no-elements   ' => 'Do not include elements templates'
    }
    USAGE_INFO = %Q^[options] model-file1.puml [model-file2.puml ... model-fileN.puml]
      \n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^
    #   or
    #   \r\t#{COMMAND_PREFIX} [options] --puml=DIR

    def initialize
      @template_file = DEFAULT_FILENAME
    end

    def do_job(args)
      @cd = CovData.new
      model_files = process_args args
      usage 'Missed model file', USAGE_INFO if model_files.empty?
      parse_models model_files
      @cd.set_processing_date
      @cd.type = CoverageDataType::TEMPLATE
      @cd.save(@template_file)
    end

    private

    def process_args(args)
      template_file_option = args.grep(/--template-file=.*/)[0]
      if template_file_option
        @template_file = File.expand_path template_file_option.gsub(/.*=(.+)/, '\1')
        args.delete_if { |e| e == template_file_option }
      end
      return args
    end

    def parse_models(model_files)
      Log.debug "Will parse model files #{model_files}"
      model_files.each { |lf| parse lf }
    end

    def parse(model)
      model_file = File.expand_path model
      File.open(model_file) do |f|
        begin
          current_screen = $default_screen
          curr_screen_data = nil
          while (line = f.readline.chomp)
            case line
              when ModelPatterns.current_screen_start
                name = $~[1] # $~ - is MatchData of the latest regexp match
                current_screen = name
                cur_screen_data = @cd.add_screen name

              when ModelPatterns.current_screen_end
                current_screen = nil

              when ModelPatterns.transition
                name, to = $~[1..2]
                if current_screen.nil?
                  Log.error %Q^
                    Wrong model: Transition #{name} is done from unknown screen.
                    Found in model #{model_file} at line #{f.lineno}
                            ^
                end
                cur_screen_data.add_transition name, to

              when ModelPatterns.action
                name = $~[1]
                if current_screen.nil?
                  Log.error %Q^
                    Wrong model: Action #{name} is done on unknown screen.
                    Found in model #{model_file} at line #{f.lineno}
                            ^
                end
                cur_screen_data.add_action name

              when ModelPatterns.check
                name = $~[1]
                if current_screen.nil?
                  Log.error %Q^
                    Wrong model: Action #{name} is done on unknown screen.
                    Found in model #{model_file} at line #{f.lineno}
                            ^
                end
                cur_screen_data.add_check name

              when ModelPatterns.element
                name = $~[1]
                cur_screen_data.add_element name

              else
                #d line
            end
          end
        rescue EOFError => err
          # it's ok
        end
      end
      @cd.add_input_file model_file, File.mtime(model_file).strftime('%F %R:%S.%3N')
    end

  end
end

