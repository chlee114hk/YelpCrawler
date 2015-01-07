YelpCrawler is a web crawler to crawl US Business infomation from www.yelp.com

## System dependencies
Require installation of Redis and Imagemagick

```
brew install redis
brew install imagemagick
```

## Usage

### App setup

```
bundle exec redis-server
bundle exec sidekiq -C config/sidekiq.yml
bundle exec rake yelp_crawler
```

## Web interface

```
http://localhost:3000/sidekiq/
```


## YAML file config

Number of workers can be set by yourself.
For example in config/sidekiq.yml

```
:concurrency: 5
:pidfile: tmp/pids/sidekiq.pid
test:
  :concurrency: 25
development:
  :concurrency: 25
production:
  :concurrency: 25
:queues:
  - [area_crawler, 3]
  - [business_link_finder, 7]
  - [business_info_crawler, 5]
  - default
```


## Distributed settings

For spliting data among multiple Redis instances, edit config/redis.yml

```
defaults: &defaults
  host: localhost
  port: 6379

development:
  <<: *defaults

test:
  <<: *defaults

staging:
  <<: *defaults

production:
  <<: *defaults
```

See also, initializers/sidekiq_init.rb

```
datastore_config = YAML.load(ERB.new(File.read(File.join(Rails.root, "config", "redis.yml"))).result)

datastore_config = datastore_config["defaults"].merge(datastore_config[::Rails.env])

if datastore_config[:host].is_a?(Array)
  if datastore_config[:host].length == 1
    datastore_config[:host] = datastore_config[:host].first
  else
    datastore_config = datastore_config[:host].map do |host|
      host_has_port = host =~ /:\d+\z/

      if host_has_port
        "redis://#{host}/#{datastore_config[:db] || 0}"
      else
        "redis://#{host}:#{datastore_config[:port] || 6379}/#{datastore_config[:db] || 0}"
      end
    end
  end
end

Sidekiq.configure_server do |config|
  config.redis = ::ConnectionPool.new(:size => Sidekiq.options[:concurrency] + 2, :timeout => 2) do
    redis = if datastore_config.is_a? Array
      Redis::Distributed.new(datastore_config)
    else
      Redis.new(datastore_config)
    end

    Redis::Namespace.new('resque', :redis => redis)
  end
end
```

## Custom usage
By default, the app use a data file for US boundary.

You can define your boundary for crawler by running following code in rails console

```
YelpCrawler.crawl_inside_boundary(boundary, interval)
```

## CSS

You may need to run the following code in order to see proper css in development.
```
RAILS_ENV=development bundle exec rake assets:precompile
```