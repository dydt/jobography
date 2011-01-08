require 'net/http'
require 'cgi'
require 'sanitize'

class IndeedScraper
  
  # API docs at https://ads.indeed.com/jobroll/xmlfeed

  def initialize
    @baseURL = 'http://api.indeed.com/ads/apisearch?'
    
    @params = { :publisher => '2514334929527745',
      :v => 2,
      :format => 'json',
      :co => 'us',
      :chnl => '',
      :latlong => '1',
      :userip => '127.0.0.1',
      :useragent => 'Mozilla//4.0(Firefox)'
    }
  end
  
  def search(query, location, type, limit, params = {})    
    params = @params.merge(params)
    params[:q] = query
    params[:l] = location
    params[:jt] = type
    params[:limit] = limit
    
    qURL = @baseURL
    params.each_pair do |k, v| 
      qURL += "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}&"
    end
        
    url = URI.parse(qURL)
    resp = ''
    begin
      resp = Net::HTTP.get(url)
    rescue Net::HTTPError
      return []
    end
        
    jsonResults = JSON.parse(resp)
    return [] unless jsonResults
    
    jsonResults['results'].map do |o|
      j = Job.new
      j.title = o['jobtitle']
      j.job_type = type
      j.company = o['company']
      j.orig_id = o['jobkey']
      j.pay = -1
      j.date = o['date']
      j.source = o['url']
      
      j.desc = Sanitize.clean(o['snippet'], Sanitize::Config::RESTRICTED)
      j.desc.gsub! /\n/, ''
      
      j.lat = o['latitude']
      j.long = o['longitude']
      j.state = o['state']
      j.city = o['city']
      j.zip = -1
      
      j
    end
  end
end
    