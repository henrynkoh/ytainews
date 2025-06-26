class Api::V1::CrawlerController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def start
    NewsCrawlerJob.perform_later
    
    render json: { 
      status: 'success', 
      message: 'News crawling started',
      timestamp: Time.current
    }
  end
end 