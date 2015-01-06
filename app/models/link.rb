#require 'yelp_crawler_module'

class Link < ActiveRecord::Base
	include YelpCrawlerModule

  belongs_to :business

	attr_accessible :biz_link, :business

	YELP_BASE_URL = "http://www.yelp.com/"
	YELP_BUSINESS_URL = YELP_BASE_URL + "biz/"

	def business_url
		YELP_BUSINESS_URL + biz_link
	end

	def populate_business
		html = YelpCrawler.get_content(business_url)
		parsed = Nokogiri::HTML(html)

		self.class.detect_recaptcha(parsed)

		name = parsed.css('.biz-page-title').text.strip
		website = parsed.css('.biz-website a').text.strip
		phone_number = parsed.css('.biz-phone').text.strip
		rating = parsed.css('div.biz-rating meta[itemprop=ratingValue]').first
		price = parsed.css('.price-range').first
		postal_code = parsed.css('address span[itemprop=postalCode]').text.strip
		state = parsed.css('address span[itemprop=addressRegion]').text.strip

		attributes = {}
		attributes[:name] = name
		attributes[:website] = website if website
		attributes[:phone_number] = phone_number if phone_number
		attributes[:rating] = rating['content'] if rating
		attributes[:price] = price.text.strip.scan(/\$/).size if price
		attributes[:street_address] = parsed.css('address span[itemprop=streetAddress]').text.strip
		attributes[:city] = parsed.css('address span[itemprop=addressLocality]').text.strip
		attributes[:state] = state if state && state.length
		attributes[:postal_code] = postal_code if postal_code && postal_code.length

		map_data = parsed.css(".lightbox-map")
		attrs = map_data.first['data-googlead-attrs']
		attrs_array = JSON.parse(attrs) if attrs

		attributes[:country] = attrs_array.assoc('country')[1] if attrs_array.assoc('country')
		attributes[:zipcode] = attrs_array.assoc('zipcode')[1] if attrs_array.assoc('zipcode')

		state = map_data.first['data-map-state']
		state_json = JSON.parse(state) if state

		attributes[:latitude] = state_json['center']['latitude'].to_f if state_json['center']
		attributes[:longitude] = state_json['center']['longitude'].to_f if state_json['center']

		attributes[:category] = []
		parsed.css('.category-str-list').each do |cl|
			cl.text.split(",").each do |c|
				cat = Category.find_by(name: c.strip)
				if !cat
					cat = Category.create({name: c.strip})
				end
				attributes[:category] << cat
			end
		end

		business = business_id ? Business.find_by_id(business_id) : Business.new
		if business.update_attributes(attributes)
			self.business = business
			self.save
		end
	end

	class << self
		include YelpCrawlerModule

		def grep_links(long1, lat1, long2, lat2)
			offset = 0
			page_to_fetch = search_page_url(long1, lat1, long2, lat2, offset)
			html = YelpCrawler.get_content(page_to_fetch)
			parsed = Nokogiri::HTML(html)

			detect_recaptcha(parsed)

			page_of_pages = parsed.css('.page-of-pages').text.strip.match(/^Page\s+(?<current>\d+)\s+of\s+(?<total>\d+)$/)
			pagination = parsed.css('.pagination-results-window').text.strip.match(/^Showing\s+(?<start>\d+)-(?<end>\d+)\s+of\s+(?<total>\d+)$/)

			raise MissingExpectedContent,"Expected cotent missing when fetching " + page_to_fetch unless page_of_pages && pagination

			populate_link(parsed)

			total_pages = page_of_pages[:total].to_i
			range = pagination[:end].to_i - pagination[:start].to_i + 1
			total_results = pagination[:total].to_i

			if (total_results > total_pages * range)
				mid_long = (long1 + long2) / 2.0
				mid_lat = (lat1 + lat2) / 2.0
				BusinessLinkFinder.perform_async(long1, mid_lat, mid_long, lat2)
				BusinessLinkFinder.perform_async(long1, lat1, mid_long, mid_lat)
				BusinessLinkFinder.perform_async(mid_long, mid_lat, long2, lat2)
				BusinessLinkFinder.perform_async(mid_long, lat1, long2, mid_lat)
				return
			end

			page = 1
			while (page <= total_pages)
				html = YelpCrawler.get_content(search_page_url(long1, lat1, long2, lat2, offset))
				parsed_html = Nokogiri::HTML(html)
				detect_recaptcha(parsed_html)
				populate_link(parsed_html)
				offset = page * range
				page += 1
			end
		end

		def search_page_url(long1, lat1, long2, lat2, offset)
			long1 = long1.to_s
			lat1 = lat1.to_s
			long2 = long2.to_s
			lat2 = lat2.to_s
			offset = offset.to_s
			YELP_BASE_URL + "/search?" + "cflt=shopping" + "&l=g:" + long1 + "," + lat1 + ',' + long2 + ',' + lat2 + '&start=' + offset
		end

		def populate_link(parsed_html)
			links = parsed_html.css('a.biz-name')
			biz_links = []
			links.each do |link|
				href = link["href"]
				biz_link = href.match(/\/biz\/(.*)/)
				next unless biz_link
				biz_link = biz_link[1].gsub(/\?.*/, '')
				biz_links << biz_link
				if !Link.find_by(biz_link: biz_link)
					business_link = Link.create(biz_link: biz_link)
					BusinessInfoCrawler.perform_async(business_link.id)
				end
			end
			biz_links
		end

		def detect_recaptcha(parsed_html)
			recaptcha = parsed_html.css('input[name=recaptcha_response_field]')

			raise BlockedByRecaptcha,"Blocked by recaptcha! Please go to yelp page and solve the recaptcha manually." unless recaptcha.empty?
		end

	end
end
