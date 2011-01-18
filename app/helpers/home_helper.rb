require 'URI'

module HomeHelper
  def recent_search_link(search)
    s = "<a href=#{search_path}?q=#{URI::escape search.query}" +
    "&l=#{URI::escape search.location}>"
    if (search.query != '' and search.location != '')
      s + "#{h search.query} near #{h search.location}</a>?"
    elsif (search.query != '')
      s + "#{h search.query}</a> jobs?"
    else
      "jobs near " + s + "#{h search.location}</a>?"
    end
  end
end
