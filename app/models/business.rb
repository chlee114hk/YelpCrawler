class Business < ActiveRecord::Base
  has_and_belongs_to_many :category

  attr_accessible :category, :name, :website, :phone_number, :rating, :price, :street_address, :city,
    :state, :country, :postal_code, :zipcode, :latitude, :logitude

	geocoded_by :full_street_address   # can also be an IP address
	after_validation :geocode          # auto-fetch coordinates
	
  def full_street_address
    "#{street_address} #{city}, #{state}"
  end
	
	def marker_url
		marker_pic_url(category.first.color[1..-1]) if category
	end
	
	private
	
	def marker_pic_url(color)
		"http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|" + color + "|000000"
	end
end
