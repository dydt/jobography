class HomeController < ApplicationController

  def welcome
    @rand_jobs = []
    count = [30, Job.count].min
    while @rand_jobs.length < count
      i = rand(Job.count)
      j = Job.first(:offset => i)
      @rand_jobs.push(j) if j.lat
    end
  end

end
