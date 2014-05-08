$redis = Redis.new(host: Rails.env.production? ? ENV['REDISTOGO_URL'] : 'localhost', port: 6379)
