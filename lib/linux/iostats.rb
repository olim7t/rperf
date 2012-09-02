# Processes an `iostat -xmdt` report
class Iostats
  def initialize(basedir)
    @basedir = basedir
    @raw_iostats = File.join(basedir, 'iostat.log')
  end

  # Splits the data into one file per device
  #
  # Example input:
  #
  #   07/30/2012 03:14:02 PM
  #
  #   Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await  svctm  %util
  #   sda               5.73   147.96   17.00   19.52     1.37     0.65   113.20     0.09    2.51   0.54   1.97
  #
  #   07/30/2012 03:14:07 PM
  #
  #   Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await  svctm  %util
  #   sda               0.00   168.60    0.00   22.80     0.00     0.75    66.95     0.00    0.04   0.04   0.08
  #
  # Output (in iostat_sda.log)
  # 03:14:02 sda               5.73   147.96   17.00   19.52     1.37     0.65   113.20     0.09    2.51   0.54   1.97
  # 03:14:07 sda               0.00   168.60    0.00   22.80     0.00     0.75    66.95     0.00    0.04   0.04   0.08
  def split
    out_streams = Hash.new do |hash, device|
      hash[device] = File.open(File.join(@basedir, "iostat_#{device}.log"), "w")
      hash[device]
    end

    current_time = nil
    IO.foreach(@raw_iostats) do |line|
      if /\d{2}\/\d{2}\/\d{2,4} (?<time>\d\d:\d\d:\d\d).*/ =~ line
        current_time = time
      elsif /^(?<device>\w+)\s+\d+\.\d+\s+\d+\.\d+/ =~ line
        out_streams[device].puts "#{current_time} #{line}"
      end
    end

    out_streams.each_entry do |device, stream|
      stream.close
    end
  end
end
