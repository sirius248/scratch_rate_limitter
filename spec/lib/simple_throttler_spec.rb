require 'rails_helper'

RSpec.describe SimpleThrottler do
  let(:request1) {
    Rack::Request.new(
      Rack::MockRequest.env_for("http://example.com/home", "REMOTE_ADDR" => "1.2.3.4")
    )
  }

  let(:request2) {
    Rack::Request.new(
      Rack::MockRequest.env_for("http://example.com/testing", "REMOTE_ADDR" => "1.2.3.4")
    )
  }

  before do
    SimpleThrottler.configure do
      throttle "/testing", limit: 10, period: 1.hours
      throttle "/home", limit: 20, period: 2.hours
    end
  end

  describe '#configure' do
    it 'add throttle endpoints' do
      expect(SimpleThrottler.endpoints).to include("/testing")
      expect(SimpleThrottler.instance.data["/testing"][:limit]).to eq(10)
      expect(SimpleThrottler.instance.data["/testing"][:period]).to eq(1.hours)

      expect(SimpleThrottler.endpoints).to include("/home")
      expect(SimpleThrottler.instance.data["/home"][:limit]).to eq(20)
      expect(SimpleThrottler.instance.data["/home"][:period]).to eq(2.hours)
    end
  end

  describe '#throttle_for' do
    it "throttle the endpoind" do
      SimpleThrottler.throttle_for(request1)
      key, = SimpleThrottler.key_and_expires_in(request1)

      expect(SimpleThrottler.instance.cache_store.read(key)).to eq(1)

      4.times { SimpleThrottler.throttle_for(request1) }

      expect(SimpleThrottler.instance.cache_store.read(key)).to eq(5)
    end
  end

  describe '#exceed_limit?' do
    it "return true when exceed the limit" do
      21.times { SimpleThrottler.throttle_for(request2) }

      expect(SimpleThrottler.exceed_limit?(request2)).to eq(true)
    end
  end
end
