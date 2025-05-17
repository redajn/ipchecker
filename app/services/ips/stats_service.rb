module Ips
  class StatsService < BaseService
    Contract = Ips::StatsContract.new

    def call(input)
      data = yield validate(input, Contract)
      ip = yield fetch_ip(data[:id])
      stats = yield aggregate_stats(ip, data[:from], data[:to])

      Success(stats)
    end

    private

    def fetch_ip(id)
      ip = Ip[id]
      ip ? Success(ip) : Failure(code: :not_found)
    end

    def aggregate_stats(ip, from_s, to_s)
      from, to = parse_interval(from_s, to_s)

      sql = <<~SQL
        SELECT
          COUNT(*) AS total,
          COUNT(*) FILTER (WHERE success) AS success,
          MIN(rtt) AS min_rtt,
          MAX(rtt) AS max_rtt,
          AVG(rtt) AS avg_rtt,
          STDDEV_SAMP(rtt) AS stddev_rtt,
          PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rtt) AS median_rtt,
          ((COUNT(*) FILTER (WHERE NOT success) * 100.0) / NULLIF(COUNT(*), 0)::float) AS loss_percent
        FROM pings
        WHERE ip_id = ?
          AND created_at BETWEEN ? AND ?
      SQL

      row = DB[sql, ip.id, from, to].first
      return Failure(code: :not_found) if row[:total].nil? || row[:total].zero?

      Success({ ip: ip.ip, from: from_s, to: to_s }.merge(format_stats_row(row)))
    end

    def format_stats_row(row)
      {
        total: row[:total],
        success: row[:success],
        loss_percent: row[:loss_percent]&.round(2),
        min_rtt: row[:min_rtt]&.round(2),
        max_rtt: row[:max_rtt]&.round(2),
        avg_rtt: row[:avg_rtt]&.round(2),
        median_rtt: row[:median_rtt]&.round(2),
        stddev_rtt: row[:stddev_rtt]&.round(2)
      }
    end

    def parse_interval(from_s, to_s)
      [Time.iso8601(from_s), Time.iso8601(to_s)]
    end
  end
end
