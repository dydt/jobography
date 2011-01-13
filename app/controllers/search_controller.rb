require 'indeed_scraper'

class SearchController < ApplicationController
  def search
    # Render a static-ish template with javascript to fetch the actual results
    @query = params[:q]
    @location = params[:l]
  end
  
  def results
    # Gets called by ajax, returns results as json
    @query = params[:q]
    @location = params[:l]

    idsr = IndeedScraper.new
    api_results = idsr.search(@query, @location, '', 25)
    render :json => api_results    
  end
end
