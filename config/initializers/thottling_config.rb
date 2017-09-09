require_relative '../../lib/simple_throttler'

SimpleThrottler.configure do
  throttle "/home/index", limit: 5, period: 1.hours
end
