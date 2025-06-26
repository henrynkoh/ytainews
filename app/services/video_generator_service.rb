class VideoGeneratorService
  def initialize(news_article)
    @article = news_article
  end
  
  def generate
    start_time = Time.current
    @article.log_step('video', 'processing')
    
    # Generate background image
    background_path = generate_background_image
    
    # Create video using FFmpeg
    output_path = compose_video(background_path)
    
    @article.update!(
      video_file_path: output_path,
      background_image_path: background_path,
      duration: get_video_duration(output_path),
      status: 'video_ready'
    )
    
    processing_time = Time.current - start_time
    
    @article.log_step('video', 'success', 
                     processing_time: processing_time,
                     metadata: { 
                       file_size: File.size(output_path),
                       duration: @article.duration 
                     })
    
    output_path
  rescue => e
    @article.log_step('video', 'failed', error_message: e.message)
    @article.update!(status: 'failed')
    raise e
  end
  
  private
  
  def generate_background_image
    # Create a simple animated background using Ruby
    background_filename = "bg_#{@article.id}_#{Time.current.to_i}.mp4"
    background_path = Rails.root.join('tmp', background_filename)
    
    # Create animated gradient background with FFmpeg
    cmd = [
      'ffmpeg',
      '-f', 'lavfi',
      '-i', '"color=c=0x1e3a8a:duration=45:size=1080x1920:rate=30"',
      '-vf', '"drawtext=fontfile=/System/Library/Fonts/Arial.ttf:text=\'AI NEWS\':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=(h-text_h)/2"',
      '-t', '45',
      '-y',
      background_path.to_s
    ].join(' ')
    
    system(cmd)
    background_path.to_s
  end
  
  def compose_video(background_path)
    output_filename = "video_#{@article.id}_#{Time.current.to_i}.mp4"
    output_path = Rails.root.join('tmp', output_filename)
    
    # Combine background, audio, and subtitles
    cmd = [
      'ffmpeg',
      '-i', background_path,                    # Background video
      '-i', @article.audio_file_path,          # Audio
      '-vf', build_video_filters,              # Video filters (subtitles, effects)
      '-c:v', 'libx264',                       # Video codec
      '-c:a', 'aac',                           # Audio codec
      '-preset', 'fast',                       # Encoding preset
      '-crf', '23',                           # Quality
      '-shortest',                            # Stop when shortest input ends
      '-y',                                   # Overwrite output
      output_path.to_s
    ].join(' ')
    
    success = system(cmd)
    
    unless success
      raise "FFmpeg failed to create video"
    end
    
    output_path.to_s
  end
  
  def build_video_filters
    filters = []
    
    # Scale to vertical format
    filters << 'scale=1080:1920'
    
    # Add subtle zoom effect
    filters << 'zoompan=z=\'min(zoom+0.0015,1.5)\':d=25*30:x=iw/2-(iw/zoom/2):y=ih/2-(ih/zoom/2)'
    
    # Add title text overlay
    title_text = @article.title.gsub("'", "\\\\'").truncate(60)
    filters << "drawtext=fontfile=/System/Library/Fonts/Arial Bold.ttf:text='#{title_text}':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=h*0.15:enable='between(t,1,8)'"
    
    # Add source text
    filters << "drawtext=fontfile=/System/Library/Fonts/Arial.ttf:text='#{@article.source}':fontcolor=gray:fontsize=32:x=(w-text_w)/2:y=h*0.85:enable='between(t,1,40)'"
    
    filters.join(',')
  end
  
  def get_video_duration(video_path)
    # Use ffprobe to get video duration
    cmd = "ffprobe -v quiet -show_entries format=duration -of csv=p=0 '#{video_path}'"
    duration_str = `#{cmd}`.strip
    duration_str.to_f
  rescue
    40.0  # Default duration
  end
end 