class ScriptGeneratorService
  def initialize(news_article)
    @article = news_article
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end
  
  def generate
    start_time = Time.current
    @article.log_step('script', 'processing')
    
    prompt = build_script_prompt
    
    response = @client.chat(
      parameters: {
        model: "gpt-4",
        messages: [{ role: "user", content: prompt }],
        max_tokens: 400,
        temperature: 0.7
      }
    )
    
    script_content = response.dig("choices", 0, "message", "content")
    
    @article.update!(
      script: script_content,
      hook: extract_hook(script_content),
      key_points: extract_key_points(script_content),
      status: 'script_ready'
    )
    
    processing_time = Time.current - start_time
    cost = calculate_openai_cost(response)
    
    @article.log_step('script', 'success', 
                     processing_time: processing_time, 
                     cost: cost,
                     metadata: { model: 'gpt-4', tokens: response.dig("usage", "total_tokens") })
    
    script_content
  rescue => e
    @article.log_step('script', 'failed', error_message: e.message)
    @article.update!(status: 'failed')
    raise e
  end
  
  private
  
  def build_script_prompt
    """
    AI/LLM 뉴스를 30-40초 YouTube Shorts용 스크립트로 작성해주세요.

    뉴스 제목: #{@article.title}
    뉴스 내용: #{@article.content}
    출처: #{@article.source}

    요구사항:
    1. 정확히 30-40초 분량 (약 80-100단어)
    2. 첫 3초에 강력한 훅(Hook) 포함 - 시청자 주의 끌기
    3. 핵심 정보를 3가지 포인트로 압축
    4. 마지막에 행동 유도 (CTA) 포함
    5. 일반인도 이해하기 쉬운 언어 사용
    6. 흥미롭고 역동적인 표현 사용
    7. 한국어로 작성

    스크립트 구조:
    - 훅 (3초): 충격적이거나 흥미로운 첫 문장
    - 본문 (30초): 핵심 내용 3가지
    - CTA (5초): 구독/좋아요 요청

    스크립트:
    """
  end
  
  def extract_hook(script)
    # Extract first sentence as hook
    script.split('.').first&.strip
  end
  
  def extract_key_points(script)
    # Simple extraction of key points (could be enhanced with AI)
    script.split('.').select(&:present?).map(&:strip)[1..-2] || []
  end
  
  def calculate_openai_cost(response)
    # GPT-4 pricing as of 2024
    input_tokens = response.dig("usage", "prompt_tokens") || 0
    output_tokens = response.dig("usage", "completion_tokens") || 0
    
    (input_tokens * 0.03 / 1000) + (output_tokens * 0.06 / 1000)
  end
end 