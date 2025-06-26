class AudioGeneratorJob < ApplicationJob
  queue_as :ai_processing
  
  def perform(article_id)
    article = NewsArticle.find(article_id)
    return unless article.status == 'script_ready'
    
    AudioGeneratorService.new(article).generate
  end
end 