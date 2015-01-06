require 'yelp_crawler_module'
class AreaCrawler
	include Sidekiq::Worker
  sidekiq_options :queue => :area_crawler, :backtrace => true

	def perform(boundary, interval)
		YelpCrawlerModule::YelpCrawler.crawl_inside_boundary(boundary, interval)
	end
end