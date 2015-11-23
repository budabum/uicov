#=======
# Author: Alexey Lyanguzov (budabum@gmail.com)
#=======

module UICov
  class Report < Command
    DEFAULT_FILENAME = 'uicov.report.html'
    OPTIONS = {
      '--report-file=FILE' => "File to store report [default is '#{DEFAULT_FILENAME}']",
      # '--format=FORMAT  ' => 'Report format. One of: html, puml [default is "html"]',
      # '--no-transitions ' => 'Do not report transitions coverage',
      # '--no-actions     ' => 'Do not report actions coverage',
      # '--no-checks      ' => 'Do not report checks coverage',
      # '--no-elements    ' => 'Do not report elements coverage'
    }
    USAGE_INFO = %Q^[options] file1.uic [file2.uic ... fileN.uic]
      \n\rWhere options are:
      #{OPTIONS.inject([]){|a, e| a << "\r\t#{e[0]}\t- #{e[1]}"; a}.join("\n")}
    ^

    def initialize
      @report_file = DEFAULT_FILENAME
    end

    def do_job(args)
      usage 'Missed coverage file', USAGE_INFO if args.empty?
      cov_files = process_args args
      @cd = merged_file(cov_files)
      @html = ''
      @html << add_header
      @html << create_summary_report
      @html << create_screens_summary_report
      @html << create_per_screen_report
      save @report_file
    end

    private
    def process_args(args)
      report_file_option = args.grep(/--report-file=.*/)[0]
      if report_file_option
        @report_file = File.expand_path report_file_option.gsub(/.*=(.+)/, '\1')
        args.delete_if { |e| e == report_file_option }
      end
      return args
    end

    def merged_file(cov_files)
      cov_files.size > 1 ? Merge.new.merge(cov_files) : CovData.load(cov_files.first)
    end

    def add_header
      %Q^
<style>
.covtable{
  border: thin solid black;
  text-align: left;
}
BODY,TABLE {font-size: small}
H2{text-align:center;}
TH{border:thin solid black;text-align:center; background-color: #CCCCCC}
TD{border:thin solid black;text-align:right}
TD.namecol{border:thin solid black;text-align:left}
CAPTION{text-align: left; font-weight: bold}
</style>
      ^
    end

    def create_summary_report
      %Q^
        <h1>Summary Report</h1>
      ^
    end

    def create_screens_summary_report
      # tr_line1 = "<tr><td><b>%s</b></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>"
      tr_line2 = "<tr>
        <td class='namecol'><b>%s</b></td>
        <td>%s</td><td>%s</td><td>%s</td>
        <td>%s</td><td>%s</td><td>%s</td>
        <td>%s</td><td>%s</td><td>%s</td>
        <td>%s</td><td>%s</td><td>%s</td>
      </tr>"
      str_res = %Q^
        <h1>Screens Summary Report</h1>
        <table width='80%'>
        <tr><th rowspan='2'>Screen</th><th colspan='3'>Elements</th><th colspan='3'>Transitions</th><th colspan='3'>Actions</th><th colspan='3'>Checks</th></tr>
        <tr><th>Hit</th><th>All</th><th>%</th><th>Hit</th><th>All</th><th>%</th><th>Hit</th><th>All</th><th>%</th><th>Hit</th><th>All</th><th>%</th></tr>
      ^
      total = @cd.screens.inject([0,0,0, 0,0,0, 0,0,0, 0,0,0]) do |arr, pair|
        name, screen = pair
        ec = [screen.get_count(:elements, true), screen.get_count(:elements), screen.get_coverage(:elements)]
        tc = [screen.get_count(:transitions, true), screen.get_count(:transitions), screen.get_coverage(:transitions)]
        ac = [screen.get_count(:actions, true), screen.get_count(:actions), screen.get_coverage(:actions)]
        cc = [screen.get_count(:checks, true), screen.get_count(:checks), screen.get_coverage(:checks)]
        str_res << tr_line2 % [name, *ec, *tc, *ac, *cc]
        arr
      end
      str_res << %Q^
        #{tr_line2 % ['Total', *total]}
        </table>
      ^
    end
    #{@cd.screens.keys.map{|k| "#{tr_line % [k,'','','','']}".join("\n")}

    def create_per_screen_report
      %Q^
        <h1>Detailed Report</h1>
        #{@cd.screens.values.map{ |s| s.report }.join("\n")}
      ^
    end

    def save(filename)
      report_file = File.expand_path filename
      File.open(report_file, 'w'){|f| f.write(@html)}
      Log.info "Result saved into file #{report_file}"
    end
  end
end

