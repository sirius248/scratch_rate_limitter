class SimpleThrottler
  include Singleton

  attr_accessor :data, :cache_store
  attr_reader :default_period, :default_limit

  def initialize
    @data = {}
    @cache_store = ActiveSupport::Cache::MemoryStore.new
    @default_period = 1.hours
    @default_limit = 100
  end

  def add(key, value)
    @data[key] = value
  end

  class << self
    def configure(&block)
      if block_given?
        class_eval(&block)
      end
    end

    def throttle(endpoint, opts)
      instance.add(endpoint, opts)
    end

    def endpoints
      instance.data.keys
    end

    def throttle_for(req)
      period = (instance.data[req.path][:period] || instance.default_period).to_i
      epoch_time = Time.current.to_i
      expires_in = (period - (epoch_time % period) + 1)
      key = "req/ip:#{req.ip}:#{(epoch_time / period)}"

      result = instance.cache_store.increment(key, 1, expires_in: expires_in)

      if result.nil?
        instance.cache_store.write(key, 1, expires_in: expires_in)
      end

      result || 1
    end

    def exceed_limit?(req)
      period = (instance.data[req.path][:period] || instance.default_period).to_i
      epoch_time = Time.current.to_i
      key = "req/ip:#{req.ip}:#{(epoch_time / period)}"
      count = instance.cache_store.read(key).to_i
      count > instance.data[req.path][:limit].to_i
    end

    def expires_in(req)
      period = (instance.data[req.path][:period] || instance.default_period).to_i
      epoch_time = Time.current.to_i
      expires_in = (period - (epoch_time % period) + 1)
      expires_in
    end
  end
end
