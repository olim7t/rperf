class Pidstats
  def initialize(basedir)
    @basedir = basedir
    @raw_pidstats = File.join(basedir, 'pidstat.log')
  end

  # Builds an aggregate report that sums all the processes for each time period.
  #
  # Example raw logs:
  #
  #   01:26:17 PM       PID   cswch/s nvcswch/s  Command
  #   01:26:18 PM         1      8.00      1.00  foo
  #   01:26:18 PM         2      2.00      2.00  bar
  #
  #   01:26:18 PM       PID   cswch/s nvcswch/s  Command
  #   01:26:19 PM         1      3.00      0.00  foo
  #   01:26:19 PM         2      4.00      1.00  bar
  #
  # Output:
  #
  #   01:26:18 10.00 3.00
  #   01:26:19 7.00 1.00
  def aggregate_switch_stats_to(target_file)
    out = File.open(File.join(@basedir, target_file), "w")

    current_time      = nil
    total_voluntary   = 0
    total_involuntary = 0

    IO.foreach(@raw_pidstats) do |line|
      if /(?<time>\d\d:\d\d:\d\d) ..\s+\d+\s+(?<voluntary>\d+(\.\d+)?)\s+(?<involuntary>\d+(\.\d+)?).*/ =~ line
        if time == current_time
          total_voluntary += voluntary.to_f
          total_involuntary += involuntary.to_f
        else
          out.puts "#{current_time} #{total_voluntary} #{total_involuntary}" if current_time
          current_time = time
          total_voluntary = voluntary.to_f
          total_involuntary = involuntary.to_f
        end
      end
    end
    out.close
  end

  # Computes the desirable maximum of voluntary context switches per second:
  # 5% of total cpu cycles, assuming a context switch requires 80000 cycles
  # (source: Java Performance, Charlie Hunt)
  def compute_voluntary_switch_limit
    total_cpu_frequency * 1_000_000 * 0.05 / 80_000
  end

  def total_cpu_frequency
    cpuinfo = File.join(@basedir, 'cpuinfo.log')
    IO.foreach(cpuinfo)
      .grep(/cpu MHz\s*:\s*(.*)/){$1.to_f}
      .inject(:+)
  end
end
