require 'net/http'
require 'cgi'
require 'sanitize'
require 'nokogiri'

class SimplyhiredScraper

  # API docs at https://www.jobamatic.com/a/jbb/partner-dashboard-advanced-xml-api

  def initialize
    @baseURL = 'http://api.simplyhired.com/a/jobs-api/xml-v2/'

    @params = { :pshid => '28142',
      :jbd => 'dydt.jobamatic.com',
      :ssty => 2,
      :cflg => 'r',
      :clip => '1.2.3.4'
    }

    @queryparams = { :ml => '25',
      :sb => 'rd', #{ 'rd' => relevance descending, 'ra' => relevance ascending, 'd(d|a)' => date, 't(d|a)' => title, 'c(d|a)' => company, 'l(d|a)' => location }
      :pn => '1'
    }
  end

  def search(query, location, limit, queryparams = {}, params = {})
    # Limitations:
    # => This API does not allow searching by job type, but returns it in the results
    # => Will fail if limit = 1
    # => Requires location to be of the form 'city, state'
    params = @params.merge(params)
    queryparams = @queryparams.merge(queryparams)
    queryparams[:q] = query
    queryparams[:l] = location
    queryparams[:ws] = limit
    
    qURL = @baseURL
    
    queryparams.each_pair do |k, v|
      qURL += "#{CGI::escape(k.to_s)}-#{CGI::escape(v.to_s)}/"
    end

    pURL = qURL + '?'

    params.each_pair do |k, v|
      pURL += "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}&"
    end
  
    url = URI.parse(pURL)
    #pp(url)
    resp = ''
    begin 
      resp = Net::HTTP.get(url)
    rescue Net::HTTPError
      return []
    end

    o = Nokogiri::Slop(resp)
    return [] unless o
    
    rsary = o.shrs.rs.r
    results = []
    for i in (0...rsary.length) do       # Format is different if limit = 1, this breaks
      j = Job.new
      j.title = rsary[i].jt.content
      j.company = rsary[i].cn.content
      j.source = rsary[i].src['url']
      j.job_type = ''
      j.pay = -1
      j.date = rsary[i].dp.content
      j.orig_id = ''
      
      j.lat = ''
      j.long = ''
      j.city = rsary[i].loc['cty']
      j.state = rsary[i].loc['st']
      j.zip = rsary[i].loc['postcode']
      
      j.desc = Sanitize.clean(rsary[i].e.content, Sanitize::Config::RESTRICTED)
      j.desc.gsub! /\n/, ''

      results.push(j)
    end

    return results
  end
end
