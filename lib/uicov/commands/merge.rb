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
      cov_files = process_args args
      merge(cov_files)
      @merged.save('merged.uicov')
    end

    private
    def process_args(args)
      # TODO: process --switches
      # Now only cov files are supported as arguments
      return args
    end

    def merge(cov_files)
      Log.warn 'Only one file is given. Nothing to merge.' if cov_files.size == 1
      @merged = CovData.load cov_files[0]
      cov_files[1..-1].each do |cov_file|
        @cd = CovData.load cov_file
        @cd.screens.each do |name, screen_data|
          msd = @merged.screens[name]
          if msd.nil?
            @merged.screens[name] = screen_data.dup
          else
            merge_screen_data msd, screen_data
          end
        end
      end
      return @merged
    end

    def merge_screen_data(msd, sd)
      sd.elements.each do |name, sde|
        me = msd.elements[name]
        if me.nil?
          msd.elements[name] = sde.dup
        else
          me.hit(sde.hits)
        end
      end
      sd.transitions.each do |name, sde|
        me = msd.transitions[name]
        if me.nil?
          msd.transitions[name] = sde.dup
        else
          me.hit(sde.hits)
        end
      end
      sd.actions.each do |name, sde|
        me = msd.actions[name]
        if me.nil?
          msd.actions[name] = sde.dup
        else
          me.hit(sde.hits)
        end
      end
      sd.checks.each do |name, sde|
        me = msd.checks[name]
        if me.nil?
          msd.checks[name] = sde.dup
        else
          me.hit(sde.hits)
        end
      end
    end
  end
end

