require 'net/http'
require 'cgi'
require 'sanitize'

class IndeedScraper
  
  # API docs at https://ads.indeed.com/jobroll/xmlfeed

  def initialize
    @baseURL = 'http://api.indeed.com/ads/apisearch'
  
    @pubID = '2514334929527745'
    @apiV = 2
    @format = 'json'
    @co = 'us'
    @chnl = ''
    @latlong = '1'
  
    # These need to be set dynamically, eventually
    @userip = '1.2.3.4'
    @useragent = 'Mozilla/%2F4.0%28Firefox%29'
  end
  
  def search(query, location, type, limit)
    # TODO: Error handle the shit out of this
    qURL = "#{@baseURL}?publisher=#{@pubID}&v=#{@apiV}&format=#{@format}&q=#{CGI::escape(query)}" +
            "&l=#{CGI::escape(location)}&limit=#{limit}&co=#{@co}&chnl=#{@chnl}&userip=#{@userip}" +
            "&latlong=#{@latlong}&useragent=#{@useragent}&jt=#{type}"
    url = URI.parse(qURL)
    resp = Net::HTTP.get(url)
    
    jsonResults = JSON.parse(resp)
    results = []
    jsonResults['results'].each do |o|
      j = Job.new
      j.title = o['jobtitle']
      j.job_type = type
      j.company = o['company']
      j.pay = -1
      j.date = o['date']
      j.source = o['url']
      
      j.desc = Sanitize.clean(o['snippet'], Sanitize::Config::RESTRICTED)
      j.desc.gsub! /\n/, ''
      
      j.lat = Float(o['latitude'])
      j.long = Float(o['longitude'])
      j.state = o['state']
      j.city = o['city']
      j.zip = -1
      
      results.push(j)
    end
    return results
  end
end
    