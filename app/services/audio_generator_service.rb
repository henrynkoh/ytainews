class AudioGeneratorService
  def initialize(news_article)
    @article = news_article
  end
  
  def generate
    start_time = Time.current
    @article.log_step('audio', 'processing')
    
    # Use ElevenLabs API for high-quality AI voice
    response = HTTParty.post(
      "https://api.elevenlabs.io/v1/text-to-speech/#{voice_id}",
      headers: {
        'Accept' => 'audio/mpeg',
        'xi-api-key' => ENV['ELEVENLABS_API_KEY'],
        'Content-Type' => 'application/json'
      },
      body: {
        text: @article.script,
        model_id: "eleven_multilingual_v2",
        voice_settings: {
          stability: 0.75,
          similarity_boost: 0.75,
          style: 0.5,
          use_speaker_boost: true
        }
      }.to_json
    )
    
    if response.success?
      audio_filename = "audio_#{@article.id}_#{Time.current.to_i}.mp3"
      audio_path = Rails.root.join('tmp', audio_filename)
      
      File.write(audio_path, response.body)
      
      @article.update!(
        audio_file_path: audio_path.to_s,
        status: 'audio_ready'
      )
      
      processing_time = Time.current - start_time
      cost = calculate_elevenlabs_cost(@article.script)
      
      @article.log_step('audio', 'success', 
                       processing_time: processing_time, 
                       cost: cost,
                       metadata: { voice_id: voice_id, file_size: File.size(audio_path) })
      
      audio_path.to_s
    else
      raise "ElevenLabs API error: #{response.code} - #{response.body}"
    end
  rescue => e
    @article.log_step('audio', 'failed', error_message: e.message)
    @article.update!(status: 'failed')
    raise e
  end
  
  private
  
  def voice_id
    # Korean voice ID from ElevenLabs
    ENV['ELEVENLABS_VOICE_ID'] || 'pNInz6obpgDQGcFmaJgB'  # Default Korean voice
  end
  
  def calculate_elevenlabs_cost(text)
    # ElevenLabs pricing: ~$0.30 per 1K characters
    character_count = text.length
    (character_count * 0.30 / 1000).round(4)
  end
end 