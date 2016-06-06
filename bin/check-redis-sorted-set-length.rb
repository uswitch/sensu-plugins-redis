#!/usr/bin/env ruby
#
# Checks number of items in a Redis sorted set key
# ===
#
# Depends on redis gem
# gem install redis
#
# Copyright (c) 2016, uSwitch Ltd. <waldemar.schwan@uswitch.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-plugin/check/cli'
require 'redis'

class RedisListLengthCheck < Sensu::Plugin::Check::CLI
  option :host,
         short: '-h HOST',
         long: '--host HOST',
         description: 'Redis Host to connect to',
         required: false,
         default: '127.0.0.1'

  option :port,
         short: '-p PORT',
         long: '--port PORT',
         description: 'Redis Port to connect to',
         proc: proc(&:to_i),
         required: false,
         default: 6379

  option :database,
         short: '-n DATABASE',
         long: '--dbnumber DATABASE',
         description: 'Redis database number to connect to',
         proc: proc(&:to_i),
         required: false,
         default: 0

  option :password,
         short: '-P PASSWORD',
         long: '--password PASSWORD',
         description: 'Redis Password to connect with'

  option :warn,
         short: '-w COUNT',
         long: '--warning COUNT',
         description: 'COUNT warning threshold for number of items in Redis sorted set key in range',
         proc: proc(&:to_i),
         required: true

  option :crit,
         short: '-c COUNT',
         long: '--critical COUNT',
         description: 'COUNT critical threshold for number of items in Redis sorted set key in range',
         proc: proc(&:to_i),
         required: true

  option :key,
         short: '-k KEY',
         long: '--key KEY',
         description: 'Redis sorted set KEY to check',
         required: true

  option :score_min,
         short: '-m SCORE',
         long: '--score-min SCORE',
         description: 'SCORE min score of the range to use',
         proc: proc(&:to_i),
         required: true

  option :score_max,
         short: '-M SCORE',
         long: '--score-max SCORE',
         description: 'SCORE max score of the range to use',
         proc: proc(&:to_i),
         required: true

  def run
    options = { host: config[:host], port: config[:port], db: config[:database] }
    options[:password] = config[:password] if config[:password]
    redis = Redis.new(options)

    length = redis.zcount(config[:key], config[:score_min], config[:score_max])

    if length >= config[:crit]
      critical "Redis sorted set #{config[:key]} length is above the CRITICAL limit: #{length} length / #{config[:crit]} limit"
    elsif length >= config[:warn]
      warning "Redis sorted set #{config[:key]} length is above the WARNING limit: #{length} length / #{config[:warn]} limit"
    else
      ok "Redis sorted set #{config[:key]} length is below thresholds"
    end
  rescue => e
    unknown e.message
  end
end
