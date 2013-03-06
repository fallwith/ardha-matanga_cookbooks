class RedisServerctl
  require 'fileutils'
  require 'yaml'

  def initialize(params={})
    @config_file = params['config_file'] || "#{ENV['HOME']}/dist/shared/conf/redis.yml"
    @config = YAML.load_file(@config_file).merge(params)
  end

  def start
    start_cmd = formulate_start_command
    puts "Starting Redis..."
    run start_cmd
  end

  def stop
    puts "Stopping Redis..."
    run "#{@config['install_dir']}/bin/redis-cli SHUTDOWN"
  end

  def check
    puts "Checking Redis..."
    puts "command: #{@config['check_command']}"
    result = run?(@config['check_command'])
    puts "result: #{result ? 'SUCCESS' : 'FAILURE'}"
    result
  end

  def restart
    stop
    start
  end

  def wipe
    puts "Wiping all stored Redis data..."
    run "rm -f #{@config['dump_file']}"
  end

  def cli(args)
    show_usage_and_exit if args.empty?
    allowed_actions = public_methods(false) - Array(__method__)
    if bad_action = args.detect{|a| !allowed_actions.include?(a.to_sym)}
      show_usage_and_exit("Unknown action '#{bad_action}'. Exiting.")
    end
    args.map{|a| send(a)}
  end


  private

  def formulate_start_command
    <<-EOF
      (#{@config['install_dir']}/bin/redis-server #{@config['config_file']} >/dev/null 2>&1 &) &&
      i=#{@config['startup_check_loop_count']};
      until $(#{@config['check_command']} 1>/dev/null 2>&1); do
        i=$(( $i - 1 ))
        if [ $i -lt 1 ]; then
          echo "ERROR: Redis still not reachable after #{@config['startup_check_loop_count']} ping attempts!"
          exit 1
        else
          echo "Redis not yet reachable. Sleeping #{@config['startup_check_sleep_secs']} secs (attempt $(( #{@config['startup_check_loop_count'].to_i} - $i )) of #{@config['startup_check_loop_count']})..."
        fi
        sleep #{@config['startup_check_sleep_secs']}
      done
      echo "SUCCESS - Redis has responded to a ping and is considered healthy."
    EOF
  end

  def show_usage_and_exit(error_msg=nil)
    warn error_msg if error_msg
    puts "Usage: #{$0} <action> (<action 2> <action 3> <action 4>)"
    exit
  end

  def run(cmd)
    system cmd
    raise "Error: #{cmd}: #{$?}" if $?.to_i != 0
  end

  def run?(cmd)
    begin
      run(cmd)
      true
    rescue => e
      warn e.to_s
      false
    end
  end
end
