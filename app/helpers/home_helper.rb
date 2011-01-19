module HomeHelper
  def recent_search_link(search)
    q = search.query
    l = search.location
    
    qs = URI::escape q
    ls = URI::escape l
    
    link = "<a class=recent href=#{search_path}?q=#{qs}" +
    "&l=#{ls} data-q='#{qs}' data-l='#{ls}'>"
    
    if search.query != '' and search.location != ''
      link + "#{h q} near #{h l}</a>?"
    elsif (search.query != '')
      link + "#{h q}</a> jobs?"
    else
      "jobs near " + link + "#{h l}</a>?"
    end
  end
end
