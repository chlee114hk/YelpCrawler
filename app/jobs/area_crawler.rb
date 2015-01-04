#require "yelp_crawler_module"
require "resque/errors"

class AreaCrawler
	include Resque::Plugins::UniqueJob
	extend Resque::Plugins::ExponentialBackoff

  @queue = :area_crawler

	class << self
		def perform(boundary, interval)
			YelpCrawlerModule::YelpCrawler.crawl_inside_boundary(boundary, interval)
		rescue Resque::TermException
			Rails.logger.error "AreaCrawler job cleaned up!"
		end
	end
end