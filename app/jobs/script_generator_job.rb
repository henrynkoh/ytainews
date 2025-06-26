class ScriptGeneratorJob < ApplicationJob
  queue_as :ai_processing
  
  def perform(article_id)
    article = NewsArticle.find(article_id)
    return unless article.status == 'pending'
    
    ScriptGeneratorService.new(article).generate
  end
end 