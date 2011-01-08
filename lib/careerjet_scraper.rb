require 'net/http'
require 'cgi'
require 'sanitize'
require 'careerjetr'

class CareerjetScraper

  # API docs at https://github.com/ceritium/careerjetr

  def initialize
    @params = { :keywords => '', 
      :location => '',
      :sort => 'relevance', #can be 'relevance', 'date', 'salary'
      :start_num => 1,
    }
    @language = :en_US
  end


  def search(query, location, type, period, limit, params = {})
    params = @params.merge(params)
    params[:keywords] = query
    params[:location] = location
    params[:contracttype] = type  #{ 'p' => permanent job, 'c' => contract, 't' => temporary, 'i' => training, 'v' => voluntary }
    params[:contractperiod] = period  #{ 'f' => full time, 'p' => part time }
    params[:pagesize] = limit
    
    results = []

    o = Careerjetr.new(@language, @params)
    o.jobs.each do |h|
      j = Job.new
      j.title = h['title']
      j.company = h['company']
      j.pay = h['salary']
      j.source = h['url']
      j.date = h['date']
      j.orig_id = -1
    
      if h['description'] 
        j.desc = Sanitize.clean(h['description'], Sanitize::Config::RESTRICTED)
      else 
        j.desc = ''
      end

      j.desc.gsub! /\n/
    
      j.city = (h['locations'].split(','))[0]
      j.state = (h['locations'].split(','))[1]
      j.zip = -1

      results.push(j)
    end
    
    return results
  end


end
