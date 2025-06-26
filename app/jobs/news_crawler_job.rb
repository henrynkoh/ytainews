class NewsCrawlerJob < ApplicationJob
  queue_as :crawling
  
  def perform
    NewsCrawlerService.crawl_all_sources
    
    # Trigger processing pipeline for new articles
    NewsProcessingPipelineJob.perform_later
  end
end 