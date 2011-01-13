class SearchController < ApplicationController
  def search
    # Render a static-ish template with javascript to fetch the actual results
    @q = params[:q]
    @l = params[:l]
  end
  
  def results
    # Gets called by ajax, returns results as json
    @query = params[:query]
    @location = params[:location]
  end
end
