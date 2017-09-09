require_relative 'rails_helper'

RSpec.describe HomeController do
  def app
    Rails.application
  end

  before do
    SimpleThrottler.configure do
      throttle "/home/index", limit: 10, period: 1.hours
    end
  end

  describe 'a single request' do
    let(:epoch_time) { Time.current.to_i }
    let(:period) { 1.hours.to_i }
    let(:key) { "req/ip:1.2.3.4:#{(epoch_time / period)}" }

    before { get '/home/index', {}, 'REMOTE_ADDR' => '1.2.3.4' }

    it 'should set the counter for one request' do
      expect(SimpleThrottler.instance.cache_store.read(key)).to eq(1)
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("ok")
    end
  end

  describe 'multiple requests' do
    let(:epoch_time) { Time.current.to_i }
    let(:period) { 1.hours.to_i }
    let(:key) { "req/ip:1.2.3.6:#{(epoch_time / period)}" }

    before do
      4.times do
        get '/home/index', {}, 'REMOTE_ADDR' => '1.2.3.6'
      end
    end

    it 'should set the counter for one request' do
      expect(SimpleThrottler.instance.cache_store.read(key)).to eq(4)
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("ok")
    end
  end

  describe "hit rate limit" do
    it 'changes the request status to 429' do
      11.times do |i|
        get '/home/index', {}, "REMOTE_ADDR" => "1.2.3.5"

        if i > 10
          expect(last_response.status).to eq(429)
          expect(last_response.body).to include("Rate limit exceeded.")
        end
      end
    end
  end

end
