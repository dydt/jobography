class JobsController < ApplicationController
  def show
    @job = Job.find(params[:id])
  end

  def index
    @jobs = Job.all
  end

  def json
    render :json => Job.find(params[:id])
  end

# Trying to create a distinction between showing a marker on the map for a job and showing the job in a text box.  Both of those depend on the job fulfilling the search query.
  def map
    if [@lat, @long]
    end
  end

# Getting rid of old and/or expired jobs
  def destroy
    if @date 
    end
  end

end
