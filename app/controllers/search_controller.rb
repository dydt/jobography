require 'indeed_scraper'

class SearchController < ApplicationController
  def search
    # Render a static-ish template with javascript to fetch the actual results
    @query = params[:q]
    @location = params[:l]
    @delayLoad = params[:delayLoad]
  end
  
  def results
    # Gets called by ajax, returns results as json
    @query = params[:q]
    @location = params[:l]
    
    search = Search.new
    search.query = @query
    search.location = @location
    search.user = current_user
    
    old_search = @recent_searches = Search.order('created_at DESC').first
    
    if search.query != old_search.query or search.location != old_search.location
      search.save
    end

    idsr = IndeedScraper.new
    api_results = idsr.search(@query, @location, '', 25)
    render :json => api_results    
  end
end
