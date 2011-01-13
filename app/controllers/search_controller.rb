class SearchController < ApplicationController
  def search
    # Render a static-ish template with javascript to fetch the actual results
    @query = params[:query]
    @location = params[:location]
  end
  
  def results
    # Gets called by ajax, returns results as json
    require 'indeed_scraper' 
    @query = params[:query]
    @location = params[:location]

    idsr = IndeedScraper.new
    api_results = idsr.search(@query, @location, '', 25)
    logger.debug api_results
    render :json => api_results    
  end
end
