require 'logger'

module Pings
  class PerformService < BaseService
    TIMEOUT = 1000 # ms

    def call(ids)
      ip_map = yield fetch_enabled_ips(ids)
      lines = yield execute_fping(ip_map.keys)
      metrics = yield parse_fping_output(lines, ip_map)
      yield persist_metrics(metrics)

      Success()
    rescue StandardError => e
      log_error(e)
      Failure(e)
    end

    private

    def fetch_enabled_ips(ids)
      ip_map = Ip.where(id: ids, enabled: true).select_map(%i[ip id]).to_h
      return Failure(:no_ips) if ip_map.empty?

      Success(ip_map)
    end

    def execute_fping(ips)
      cmd = ['fping', '-c1', "-t#{TIMEOUT}", '-q', *ips]
      lines = IO.popen(cmd, err: %i[child out], &:read).each_line.to_a
      return Failure(:no_output) if lines.empty?

      Success(lines)
    rescue StandardError => e
      log_error(e)
      Failure(e)
    end

    def parse_fping_output(lines, ip_map)
      metrics = lines.map { |line| build_ping_row(line, ip_map) }.compact
      Failure(:parse_error) if metrics.empty?

      Success(metrics)
    end

    def build_ping_row(line, ip_map)
      ip_str, result = line.strip.split(/\s+:/, 2)
      return unless ip_str && ip_map[ip_str]

      base = { ip_id: ip_map[ip_str],
               created_at: Time.now }

      if result.include?('100%')
        base.merge(success: false, rtt: nil)
      else
        rtt = result[/max = ([\d.]+)/, 1]&.to_f
        base.merge(success: true, rtt: rtt)
      end
    end

    def persist_metrics(rows)
      DB[:pings].multi_insert(rows)
      Success()
    rescue StandardError => e
      log_error(e)
      Failure(e)
    end

    def log_error(error)
      puts "Ping::PerformService Error running fping: #{error.class} - #{error.message}"
    end
  end
end
