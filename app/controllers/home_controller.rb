class HomeController < ApplicationController

  def welcome
    @rand_jobs = []
    10.times do
      i = rand(Job.count)
      @rand_jobs.push(Job.first(:offset => i))
    end
  end

end
