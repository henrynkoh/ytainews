#!/usr/bin/env ruby

puts "🚀 AI News Shorts - REAL DATA COMPLETE DEMONSTRATION"
puts "=" * 60

# Step 1: Clean up any existing demo data
puts "\n📋 Step 1: Cleaning up previous demo data..."
NewsArticle.where("title LIKE ?", "%REAL DATA DEMO%").destroy_all
puts "✅ Cleaned up previous demo data"

# Step 2: Create a real article for demonstration
puts "\n📡 Step 2: Creating article with REAL AI news content..."

article = NewsArticle.create!(
  title: "REAL DATA DEMO: OpenAI Releases GPT-4 Turbo with Enhanced Capabilities",
  content: "OpenAI has announced the release of GPT-4 Turbo, featuring improved reasoning capabilities, larger context windows, and enhanced multimodal understanding. The new model demonstrates significant improvements in code generation, mathematical problem-solving, and creative writing tasks. This breakthrough represents a major step forward in artificial intelligence development.",
  summary: "OpenAI unveils GPT-4 Turbo with enhanced AI capabilities",
  original_url: "https://openai.com/blog/gpt-4-turbo-enhanced-#{Time.now.to_i}",
  source: "OpenAI",
  status: 'pending'
)

puts "✅ Created demo article: #{article.title[0..50]}..."
puts "   Article ID: #{article.id}"
puts "   Source: #{article.source}"

# Step 3: Process through REAL AI pipeline
puts "\n🤖 Step 3: Starting REAL AI Pipeline Processing..."
puts "   This will use actual API calls to:"
puts "   • OpenAI GPT-4 for script generation"
puts "   • ElevenLabs for voice synthesis"  
puts "   • FFmpeg for video creation"

# Queue the job for real processing
job = NewsProcessingPipelineJob.perform_later(article.id)
puts "✅ Queued job for real processing: #{job.job_id}"

# Step 4: Monitor progress in real-time
puts "\n📊 Step 4: Real-time Progress Monitoring"
puts "=" * 40

article_id = article.id
start_time = Time.now
timeout = 300 # 5 minutes timeout

puts "🔄 Monitoring article ID #{article_id} processing..."
puts "⏱️  Timeout: #{timeout} seconds"
puts "🌐 Dashboard: http://localhost:3000/dashboard"
puts ""

loop do
  # Reload article to get latest status
  article.reload
  
  elapsed = (Time.now - start_time).to_i
  progress_info = case article.status
  when 'pending'
    { percent: 10, message: "🔄 Generating AI script...", color: "🔵" }
  when 'script_ready'
    { percent: 35, message: "🎤 Creating voice audio...", color: "🟡" }
  when 'audio_ready'
    { percent: 65, message: "🎬 Generating video...", color: "🟠" }
  when 'video_ready'
    { percent: 85, message: "📤 Uploading to YouTube...", color: "🟣" }
  when 'uploaded'
    { percent: 100, message: "✅ COMPLETE! Video uploaded!", color: "🟢" }
    break
  when 'failed'
    { percent: 0, message: "❌ FAILED - Check logs", color: "🔴" }
    break
  else
    { percent: 5, message: "⏳ Initializing...", color: "⚪" }
  end
  
  # Progress bar
  bar_length = 30
  filled_length = (bar_length * progress_info[:percent] / 100).to_i
  bar = "█" * filled_length + "░" * (bar_length - filled_length)
  
  print "\r#{progress_info[:color]} [#{bar}] #{progress_info[:percent]}% - #{progress_info[:message]} (#{elapsed}s)"
  $stdout.flush
  
  # Check for timeout
  if elapsed > timeout
    puts "\n⏰ Timeout reached (#{timeout}s) - Process may still be running"
    break
  end
  
  # Break if completed or failed
  break if ['uploaded', 'failed'].include?(article.status)
  
  sleep 3
end

puts "\n"

# Step 5: Show final results
puts "\n🎉 Step 5: Final Results"
puts "=" * 30

article.reload

puts "📊 Article Status: #{article.status}"
puts "⏱️  Total Processing Time: #{(Time.now - start_time).to_i} seconds"

if article.status == 'uploaded'
  puts "\n✅ SUCCESS! Real AI pipeline completed:"
  puts "   📝 Script: #{article.script ? 'Generated ✅' : 'Missing ❌'}"
  puts "   🎤 Audio: #{article.audio_file_path ? 'Created ✅' : 'Missing ❌'}"
  puts "   🎬 Video: #{article.video_file_path ? 'Created ✅' : 'Missing ❌'}"
  puts "   📺 YouTube: #{article.youtube_url ? 'Uploaded ✅' : 'Missing ❌'}"
  
  if article.youtube_url
    puts "\n🔗 View your video: #{article.youtube_url}"
  end
  
  # Check if files actually exist
  puts "\n📁 File Verification:"
  if article.audio_file_path
    exists = File.exist?(article.audio_file_path)
    puts "   🎤 Audio file: #{exists ? 'EXISTS ✅' : 'MISSING ❌'} (#{article.audio_file_path})"
  end
  
  if article.video_file_path
    exists = File.exist?(article.video_file_path)
    puts "   🎬 Video file: #{exists ? 'EXISTS ✅' : 'MISSING ❌'} (#{article.video_file_path})"
  end
  
elsif article.status == 'failed'
  puts "\n❌ FAILED - Check the logs for details:"
  
  # Show recent error logs
  failed_logs = GenerationLog.where(news_article: article, status: 'failed').order(created_at: :desc).limit(3)
  if failed_logs.any?
    puts "\n📋 Recent Error Logs:"
    failed_logs.each do |log|
      puts "   • #{log.step}: #{log.error_message}"
    end
  end
  
else
  puts "\n⏳ Still processing... Current status: #{article.status}"
  puts "   Check the dashboard for live updates: http://localhost:3000/dashboard"
end

puts "\n🎯 DEMONSTRATION COMPLETE!"
puts "   Dashboard: http://localhost:3000/dashboard"
puts "   Article ID: #{article.id}"
puts "=" * 60
