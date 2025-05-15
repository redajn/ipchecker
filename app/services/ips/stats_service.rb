module Ips
  class StatsService < BaseService
    Contract = Ips::StatsContract.new

    def call(input)
      data = yield validate(input, Contract)
      ip = yield fetch_ip(data[:id])
      pings = yield fetch_pings(ip.id, data[:from], data[:to])
      stats = yield build_stats(ip, data, pings)

      Success(stats)
    end

    private

    def fetch_ip(id)
      ip = Ip[id]
      ip ? Success(ip) : Failure(code: :not_found)
    end

    def fetch_pings(ip_id, from_t, to_t)
      from, to = parse_interval(from_t, to_t)
      pings = Ping.where(ip_id: ip_id, created_at: from..to)
      return Failure(code: :not_found) if pings.empty?

      Success(pings)
    end

    def build_stats(ip, data, pings)
      total     = pings.count
      success   = pings.where(success: true).count

      Success({
        ip: ip.ip,
        from: data[:from],
        to: data[:to],
        total: total,
        success: success
      }.merge(aggregate_stats(pings)))
    rescue Sequel::Error => e
      Failure(code: :stats_error, message: e.message)
    end

    def aggregate_stats(pings)
      row = DB[%(
        SELECT
          MIN(rtt) AS min_rtt,
          MAX(rtt) AS max_rtt,
          AVG(rtt) AS avg_rtt,
          STDDEV_SAMP(rtt) AS stddev_rtt,
          PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rtt) AS median_rtt,
          (100.0 * COUNT(*) FILTER (WHERE NOT success) / COUNT(*))::float AS loss_percent
        FROM pings
        WHERE id IN ?
          AND success IS NOT NULL
      ), pings.select(:id)].first

      {
        min_rtt: row[:min_rtt]&.round(2),
        max_rtt: row[:max_rtt]&.round(2),
        avg_rtt: row[:avg_rtt]&.round(2),
        median_rtt: row[:median_rtt]&.round(2),
        stddev_rtt: row[:stddev_rtt]&.round(2),
        loss_percent: row[:loss_percent]&.round(2)
      }
    end

    def parse_interval(from_t, to_t)
      [Time.iso8601(from_t), Time.iso8601(to_t)]
    end
  end
end
