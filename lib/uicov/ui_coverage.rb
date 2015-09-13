#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class UICoverage
    def cov_data
      @cd ||= CoverageData.new
    end

    def init(opts={})
#      if PATTERN_FILE.nil? or !File.exists?(PATTERN_FILE)
#        usage "Patterns file is not provided or it's absent by path: '#{PATTERN_FILE}'"
#      end
      input_log = (Opts::Files[:log] = opts[:log])
      if input_log.nil? or !File.exists?(input_log)
        UICov.usage "Input log file is not provided or it's absent by path: '#{input_log}'"
      end

      model_file = (Opts::Files[:model] = opts[:model])
      if model_file.nil? or !File.exists?(model_file)
        Log.warn "\n\n\tModel file is not provided or it's absent by path: '#{model_file}'" +
                     "\n\tYou won't be able to see uncovered metrics as well as all hits will be" +
                     "reported not as 'covered' but as 'missed in model'\n"
      end

      Opts::Patterns.keys.each {|key| Opts::Patterns[key] = opts[key] unless opts[key].nil?}

      #d "Using pattern file: #{PATTERN_FILE}"
      #d "Unsing model file: #{MODEL_FILE}"
      Log.debug "Parsing log file: #{Opts::Files[:log]}"
      return self
    end

    def parse_model
      model_file = Opts::Files[:model]
      return if model_file.nil?

      Log.debug "Loading model file: #{model_file}"

      File.open(model_file).each do |line|
        case line.chomp
          when /^['@]/ # Do nothing
          when /^\s*$/ # Do nothing
          when Opts::Patterns[:model_screen]
            name = $~[1] # $~ - is MatchData of the latest regexp match
            cov_data.add_screen name
          when Opts::Patterns[:model_transition]
            from, to, name = $~[1], $~[3], $~[4]
            cov_data.add_transition from, to, name
            cov_data.add_screen from
            cov_data.add_screen to
          else
            Log.warn "Unable to parse model line: #{line}"
        end
      end

#    %w[HomeScreen CheckoutScreen OneMoreScreen].each do |name|
#      cov_data.add_screen name
#    end
#    [%w[HomeScreen CheckoutScreen checkout], %w[CheckoutScreen OneMoreScreen one_more],
#     %w[OneMoreScreen CheckoutScreen checkout], %w[HomeScreen OneMoreScreen more]].each do |from, to, name|
#      cov_data.add_transition from, to, name
#    end
      return self
    end

    def parse_log
      transition_indexes = %w[from to name].map{|e| Opts::Patterns["transition_#{e}".to_sym]}
      File.open(Opts::Files[:log]).each do |line|
        case line
          when Opts::Patterns[:current_screen]
            name = $~[1] # $~ - is MatchData of the latest regexp match
            cov_data.hit_screen name
          when Opts::Patterns[:transition]
            from, to, name = transition_indexes.map{|i| $~[i]}
            cov_data.hit_transition from, to, name
          else
            #d line
        end
      end
    end

    def gather_coverage(opts={})
      init opts
      parse_model
      parse_log
      return cov_data
    end
  end # of UICoverage class
end
