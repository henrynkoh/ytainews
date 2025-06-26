class NewsCrawlerService
  AI_NEWS_SOURCES = [
    {
      name: 'OpenAI Blog',
      url: 'https://openai.com/blog/rss/',
      type: 'rss'
    },
    {
      name: 'Anthropic News',
      url: 'https://www.anthropic.com/news',
      type: 'html'
    },
    {
      name: 'Google AI Blog',
      url: 'https://blog.google/technology/ai/rss/',
      type: 'rss'
    },
    {
      name: 'Hugging Face Blog',
      url: 'https://huggingface.co/blog/feed.xml',
      type: 'rss'
    }
  ].freeze
  
  def self.crawl_all_sources
    AI_NEWS_SOURCES.each do |source|
      new(source).crawl
    end
  end
  
  def initialize(source)
    @source = source
  end
  
  def crawl
    case @source[:type]
    when 'rss'
      crawl_rss_feed
    when 'html'
      crawl_html_page
    end
  rescue => e
    Rails.logger.error "Error crawling #{@source[:name]}: #{e.message}"
  end
  
  private
  
  def crawl_rss_feed
    feed = Feedjira::Feed.fetch_and_parse(@source[:url])
    return unless feed
    
    feed.entries.first(5).each do |entry|
      next if NewsArticle.exists?(original_url: entry.url)
      next unless ai_related?(entry.title + ' ' + entry.summary.to_s)
      
      NewsArticle.create!(
        title: clean_title(entry.title),
        content: clean_content(entry.summary || entry.content),
        original_url: entry.url,
        source: @source[:name],
        published_at: entry.published || Time.current,
        status: 'pending'
      )
    end
  end
  
  def crawl_html_page
    # Custom HTML scraping logic for specific sites
    # Implementation depends on site structure
  end
  
  def ai_related?(text)
    ai_keywords = %w[
      artificial intelligence AI machine learning ML
      neural network deep learning GPT LLM
      OpenAI Anthropic Google Gemini Claude
      transformer model algorithm
    ]
    
    ai_keywords.any? { |keyword| text.downcase.include?(keyword.downcase) }
  end
  
  def clean_title(title)
    title.strip.gsub(/\s+/, ' ').truncate(100)
  end
  
  def clean_content(content)
    content.to_s.strip.gsub(/<[^>]*>/, '').gsub(/\s+/, ' ').truncate(1000)
  end
end 