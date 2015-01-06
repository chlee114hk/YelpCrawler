require 'yelp_crawler_module'
require 'rake'

task "start_crawl" => :environment do
	YelpCrawlerModule::YelpCrawler.start_crawl(50.0)
end

task "yelp_crawler" => :environment do
	CrawlYelp::Application.load_tasks 
	Rake::Task['start_crawl'].invoke
end