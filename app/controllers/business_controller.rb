class BusinessController < ApplicationController
  def index
    table = Business.arel_table
    have_latitude = table[:latitude].not_eq(nil)
    have_longitude = table[:longitude].not_eq(nil)
    @businesses = Business.where(have_latitude.and(have_longitude)).all
    @hash = Gmaps4rails.build_markers(@businesses) do |business, marker|
      marker.lat business.latitude
      marker.lng business.longitude
      marker.title business.name
      marker.infowindow render_to_string(
        :partial => "/business/info_window",
        :locals => { :business => business }
      )
      if business.category
        marker.json({category: business.category.map(&:name)}) if business.category
        marker.picture({
          :url    => business.marker_url,
          :width  => 32,
          :height => 32
      })
      end
    end
  end
end