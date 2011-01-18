require 'URI'

module HomeHelper
  def recent_search_link(search)
    "<a href=#{search_path}?q=#{URI::escape search.query}" +
    "&l=#{URI::escape search.location}>" +
    "#{h search.query} near #{h search.location}?</a>"
  end
end
