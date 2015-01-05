YelpCrawler is a web crawler to crawl US Business infomation from www.yelp.com

## System dependencies
Require installation of Redis and Imagemagick

...
brew install redis
brew install imagemagick
...

## Usage

### App setup

...
bundle exec redis-server
bundle exec rake resque:scheduler
bundle exec resque-pool --environment development
...

## Web interface

...
http://localhost:3000/resque/
...


## YAML file config

Number of workers can be set by yourself.
For example in config/resque-pool.yml

...
area_crawler: 2
business_link_finder: 4
business_info_crawler: 2

development:
  area_crawler: 2
  business_link_finder: 4
  business_info_crawler: 2
...


## Distributed settings

Connecnt to the same Redis instance

...
config.redis = 'localhost:6379'
...

## Custom usage
By default, the app use a data file for US boundary.

You can define your boundary for crawler by running following code in rails console

...
YelpCrawler.crawl_inside_boundary(boundary, interval)
...