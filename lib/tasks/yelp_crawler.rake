require 'yelp_crawler_module'
require 'rake'

namespace :yelp_crawler do
  task "start_crawler" => :environment do
    YelpCrawlerModule::YelpCrawler.start_crawl(50.0)
  end

  task "finish_unprocessed_links" => :environment do
    unprocessed = Link.find_by(business_id: nil)
    if unprocessed
      unprocessed.each do |link|
        BusinessInfoCrawler.perform_async(link.id)
      end
    end
  end
end

task :yelp_crawler => ['yelp_crawler:finish_unprocessed_links', 'yelp_crawler:start_crawler']

#task "yelp_crawler" => :environment do
#  CrawlYelp::Application.load_tasks
#  Rake::Task['yelp_crawler:finish_unprocessed_links'].invoke
#  Rake::Task['yelp_crawler:start_crawler'].invoke
#end