#!/usr/bin/env ruby

require_relative '../config/environment'

puts "🎯 SIMULATING REAL PROGRESS TRACKING"
puts "=" * 45
puts "This demonstrates how the progress tracking works with real data!"
puts

# Get demo articles
articles = NewsArticle.where("title LIKE ?", "%DEMO%").order(:id)

if articles.any?
  puts "📊 Found #{articles.count} demo articles to process"
  puts

  articles.each_with_index do |article, index|
    puts "📰 Article #{index + 1}: #{article.title[0..50]}..."
    
    # Simulate the pipeline stages
    statuses = [
      { status: 'pending', percentage: 10, message: 'Generating script...', time: 2 },
      { status: 'script_ready', percentage: 35, message: 'Creating audio...', time: 3 },
      { status: 'audio_ready', percentage: 65, message: 'Generating video...', time: 4 },
      { status: 'video_ready', percentage: 85, message: 'Uploading to YouTube...', time: 2 },
      { status: 'uploaded', percentage: 100, message: 'Complete!', time: 1 }
    ]
    
    statuses.each do |stage|
      article.update!(status: stage[:status])
      
      # Show progress bar
      bar_length = 30
      filled_length = (bar_length * stage[:percentage] / 100).to_i
      bar = '█' * filled_length + '░' * (bar_length - filled_length)
      
      puts "  [#{bar}] #{stage[:percentage]}% - #{stage[:message]}"
      
      # Add realistic processing time
      sleep stage[:time]
    end
    
    puts "  ✅ Article #{index + 1} completed!"
    puts
  end
  
  puts "🎉 ALL ARTICLES COMPLETED!"
  puts
  puts "📊 FINAL STATUS SUMMARY:"
  puts "=" * 30
  articles.reload.each do |article|
    puts "✅ #{article.title[0..50]}... - #{article.status.upcase}"
  end
  
  puts
  puts "💡 Now visit http://localhost:3000/dashboard to see the beautiful UI!"
  puts "📊 API: http://localhost:3000/dashboard/progress"
  
else
  puts "❌ No demo articles found. Run the real_progress_demo.rb first!"
end 