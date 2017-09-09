# Rails throttling example

[![Code Climate](https://codeclimate.com/github/kimquy/scratch_rate_limitter/badges/gpa.svg)](https://codeclimate.com/github/kimquy/scratch_rate_limitter)

[![Build Status](https://travis-ci.org/kimquy/scratch_rate_limitter.svg?branch=master)](https://travis-ci.org/kimquy/scratch_rate_limitter)

# Intro

All the main implemnetation are in the following files:

```bash
app/middleware/rack/throttling.rb
config/initializers/throttling_config.rb
lib/simple_throttler.rb
```

# Usage of SimpleThrottler

Add `throttling_config.rb` into the `initializers`

Example:

```ruby
SimpleThrottler.configure do
  throttle "/home/index", limit: 5, period: 1.hours
  throttle "/testing", limit: 20, period: 2.hours
  throttle "/awesome", limit: 100, period: 3.hours
end
```

# Improvement

At the moment the `SimpleThrottler` is super simple. The throttling algorithm only base on the IP address. And the storage only support `ActiveSupport::Cache::MemoryStore`

# Manual Testing

* Make a single request from command line with Curl

Simply copy the code below into command line. Curl is required.

```bash
curl https://scratch-rate-limitter.herokuapp.com/home/index
```

* Make multiple request from command line with Curl

```bash
for i in {1..5}; do curl https://scratch-rate-limitter.herokuapp.com/home/index; done
```

# Unit test

```ruby
bundle exec rspec
```
