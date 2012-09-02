require 'yaml'

class Rperf
  VERSION = '1.0.0'

  def initialize(basedir)
    @basedir = basedir
    @conf = YAML.load_file "#{basedir}/conf.yaml"

    create_subdir "logs"
    create_subdir "report"
  end

  def start
    each_server {|server| server.start}
    puts "\nAll done. To stop, run:
rperf stop #{@basedir}

"
  end

  def stop
    each_server {|server| server.stop}
    puts "\nAll done. To generate the reports, run:
rperf report #{@basedir}

"
  end

  def report
    each_server {|server| server.report}
  end

  def create_subdir(name)
    subdir = File.join(@basedir, name)
    Dir.mkdir(subdir) if not Dir.exists? subdir
  end

  def each_server
    @conf.each do |server_conf|
      server_conf[:alias] = server_conf[:host] if not server_conf[:alias]
      server_class = Server.for_platform server_conf[:platform]
      if !server_class
        puts "Skipping #{server_conf[:alias]}, platform #{server_conf[:platform]} not supported"
        next
      end
      yield server_class.new(@basedir, server_conf)
    end
  end
end
