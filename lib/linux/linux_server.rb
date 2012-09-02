require 'net/scp'
require 'net/ssh'
require 'archive/tar/minitar'
require 'zlib'

class LinuxServer < Server
  def initialize(parent_dir, conf)
    @conf = conf
    @logs_dir = server_dir_in File.join(parent_dir, "logs")
    @report_dir = File.expand_path(File.join(parent_dir, "report"))
    @ssh_opts = {}
    @ssh_opts[:password] = @conf[:password] if @conf[:password]
    @ssh_opts[:keys] = [ @conf[:private_key] ] if @conf[:private_key]
  end

  def start
    log 'deploying scripts'
    deploy_scripts()
    log 'starting log collection'
    remote_run("perf_logs/start.sh")
    log 'done'
  end

  def stop
    log 'stopping log collection'
    remote_run("perf_logs/stop.sh")
    log 'downloading logs'
    download_tarred_logs()
    log 'extracting logs'
    untar_logs()
    log 'done'
  end

  def report
    plot('cpu.plt', '_cpu.png')
    plot('runqueue.plt', '_runqueue.png')
    plot('memory.plt', '_memory.png')
    plot_context_switches()
    plot_iostats()
  end

  def log(message)
    puts "[#{@conf[:host]}] #{message}"
  end

  def server_dir_in(dir)
    subdir = File.join(dir, @conf[:host])
    Dir.mkdir(subdir) if not Dir.exists? subdir
    File.expand_path(subdir)
  end

  def deploy_scripts
    scripts_dir = File.join(File.dirname(__FILE__), '..', '..', 'resources', 'linux', 'perf_logs')
    Net::SCP.start(@conf[:host], @conf[:user], @ssh_opts) do |scp|
      scp.upload!(scripts_dir, '.', :recursive => true)
    end
  end

  def remote_run(command)
    Net::SSH.start(@conf[:host], @conf[:user], @ssh_opts) do |ssh|
      output = ssh.exec!(command)
      puts output
    end
  end

  def download_tarred_logs
    Net::SCP.start(@conf[:host], @conf[:user], @ssh_opts) do |scp|
      scp.download!('perf_logs/logs.tgz', @logs_dir)
    end
  end

  def untar_logs
    tar_path = File.join(@logs_dir, 'logs.tgz')
    reader = Zlib::GzipReader.new(File.open(tar_path, 'rb'))
    Archive::Tar::Minitar.unpack(reader, @logs_dir)
  end

  def plot(gnuplot_script, output_file_suffix, env = {})
    gnuplot_dir = File.join(File.dirname(__FILE__), '..', '..', 'resources', 'linux', 'gnuplot')
    Dir.chdir(@logs_dir) do
      Process.spawn(env, 'gnuplot',
                    :in => File.join(gnuplot_dir, gnuplot_script),
                    :out => File.join(@report_dir, "#{@conf[:host]}#{output_file_suffix}"))
    end
  end

  def plot_context_switches
    pidstats = Pidstats.new(@logs_dir)
    pidstats.aggregate_switch_stats_to('switches_total.log')
    limit = pidstats.compute_voluntary_switch_limit()
    plot('vcs.plt', '_vcs.png', 'LIMIT' => limit.to_s)
  end

  def plot_iostats()
    iostats = Iostats.new(@logs_dir)
    iostats.split()
    Dir.chdir(@logs_dir) do
      Dir['iostat_*.log'].each do |file|
        device = file.scan(/iostat_(.*).log/)[0][0]
        plot('iostat.plt', "_iostat_#{device}.png", 'DEVICE' => device)
      end
    end
  end
end

