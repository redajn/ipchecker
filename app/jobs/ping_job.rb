class PingJob
  TIMEOUT = 100 # ms

  def self.run
    ip_list = fetch_enabled_ips
    return if ip_list.empty?

    lines = execute_fping(ip_list)
    metrics = parse_fping_output(lines)
    persist_metrics(metrics)
  rescue StandardError => e
    log_error(e)
  end

  # ——————————————————————————————

  def self.fetch_enabled_ips
    Ip.where(enabled: true).map(&:ip)
  end

  def self.execute_fping(ip_list)
    cmd = ['fping', '-c1', "-t#{TIMEOUT}", '-q', *ip_list]
    IO.popen(cmd, err: %i[child out], &:read).each_line.to_a
  end

  def self.parse_fping_output(lines)
    lines.map { |line| parse_line(line) }.compact
  end

  def self.parse_line(line)
    ip_str, result = line.strip.split(/\s+:/)
    return unless ip_str

    ip = Ip.first(ip: ip_str)
    if result.include?('100%')
      { ip: ip, success: false, rtt: nil }
    else
      rtt = result[/max = ([\d.]+)/, 1]&.to_f
      { ip: ip, success: true, rtt: rtt }
    end
  end

  def self.persist_metrics(metrics)
    metrics.each do |attrs|
      Ping.create(
        ip_id: attrs[:ip].id,
        success: attrs[:success],
        rtt: attrs[:rtt],
        created_at: Time.now
      )
    end
  end

  def self.log_error(error)
    puts "[PingJob] Error running fping: #{error.class} - #{error.message}"
  end
end

# class PingJobOld
#   TIMEOUT = 100 # ms

#   def self.run
#     ip_list = Ip.where(enabled: true).map(&:ip)
#     return if ip_list.empty?

#     cmd = ['fping', '-c1', "-t#{TIMEOUT}", '-q', *ip_list]
#     output = IO.popen(cmd, err: %i[child out]) { |io| io.read }

#     output.each_line do |line|
#       ip, result = line.strip.split(/\s+:/)
#       next unless ip

#       if result.include?('100%')
#         Ping.create(ip: Ip.first(ip: ip), success: false)
#       else
#         match = result.match(/max = ([\d.]+)/)
#         rtt = match ? match[1].to_f : nil
#         Ping.create(ip: Ip.first(ip: ip), success: true, rtt: rtt)
#       end
#     end
#   rescue StandardError => e
#     puts "[PingJob] Error running fping: #{e.class} - #{e.message}"
#   end
# end
