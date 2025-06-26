# 📖 AI News Shorts - User Manual

**Complete Guide to Using the AI News Shorts Generator**

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Dashboard Overview](#dashboard-overview)
3. [News Crawling](#news-crawling)
4. [Processing Pipeline](#processing-pipeline)
5. [Monitoring & Analytics](#monitoring--analytics)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Configuration](#advanced-configuration)
8. [Best Practices](#best-practices)

---

## Getting Started

### First Time Setup

#### 1. Access the Dashboard
- Open your web browser
- Navigate to `http://localhost:3000/dashboard`
- You should see the AI News Shorts dashboard

#### 2. Verify System Status
Before starting, ensure all components are running:
- ✅ **Rails Server**: Should be accessible at localhost:3000
- ✅ **Background Jobs**: Check if `bin/jobs` is running
- ✅ **Database**: Verify tables are created
- ✅ **API Keys**: Confirm all keys are configured in `.env`

#### 3. Check API Connectivity
The system will automatically test API connections:
- **OpenAI**: GPT-4 access for script generation
- **ElevenLabs**: TTS service for voice generation
- **YouTube**: Upload and publishing capabilities

---

## Dashboard Overview

### Main Dashboard Sections

#### 📊 **Analytics Cards**
- **Today's Videos**: Number of videos processed today
- **Total Views**: Cumulative YouTube views across all videos
- **Success Rate**: Percentage of successful video generations
- **Pending**: Number of articles currently being processed

#### 📈 **Weekly Statistics Chart**
- Visual representation of daily video production
- Success vs. failure rates over time
- Hover for detailed daily statistics

#### 🎬 **Recent Videos List**
- Last 20 processed articles
- Real-time status updates
- Progress bars with percentage completion
- Processing time estimates

#### 🚨 **Failed Jobs Section**
- List of failed processing attempts
- Error details and retry options
- Bulk retry functionality

#### 🎛️ **Control Panel**
- **Start Crawling**: Manually trigger news crawling
- **Process Pipeline**: Start video generation pipeline
- **View Logs**: Access detailed system logs

---

## News Crawling

### Automatic Crawling

The system automatically crawls news from these sources:
- **OpenAI Blog**: Latest OpenAI announcements and research
- **Anthropic News**: Claude and safety research updates
- **Google AI Blog**: Gemini and AI research developments
- **Hugging Face Blog**: Open-source AI model releases

### Manual Crawling

#### Starting a Crawl Session
1. Click **"Start Crawling"** button on dashboard
2. Monitor the progress indicator
3. Watch for new articles appearing in the recent videos list

#### Crawling Process
1. **RSS Feed Parsing** (10-20 seconds)
   - Fetches latest articles from each source
   - Filters for new content not already processed
   - Validates article content and metadata

2. **Content Processing** (20-40 seconds)
   - Extracts article text and key information
   - Generates summaries for database storage
   - Prepares articles for script generation

3. **Queue Management** (5-10 seconds)
   - Adds new articles to processing queue
   - Sets initial status to "pending"
   - Triggers background job processing

### Crawling Results
- **Success**: New articles added to processing queue
- **No New Content**: All sources up to date
- **Partial Success**: Some sources may fail (check logs)

---

## Processing Pipeline

### Understanding the Pipeline

Each article goes through 5 distinct stages:

#### Stage 1: Script Generation (10% → 35%)
**Duration**: 1-2 minutes
**Process**:
- Article content sent to OpenAI GPT-4
- AI generates engaging Korean script
- Optimized for 30-40 second YouTube Shorts
- Includes hook, main points, and call-to-action

**Status Indicators**:
- 🔄 "Generating script..." (processing)
- ✅ Script ready (success)
- ❌ Script generation failed (error)

#### Stage 2: Audio Generation (35% → 65%)
**Duration**: 2-3 minutes
**Process**:
- Korean script sent to ElevenLabs TTS
- High-quality voice synthesis
- Audio file saved to storage
- Duration validation (30-45 seconds)

**Status Indicators**:
- 🔄 "Creating audio..." (processing)
- ✅ Audio ready (success)
- ❌ Audio generation failed (error)

#### Stage 3: Video Composition (65% → 85%)
**Duration**: 3-4 minutes
**Process**:
- FFmpeg processes audio and visual elements
- Generates animated background
- Adds text overlays and source attribution
- Creates 1080x1920 vertical video

**Status Indicators**:
- 🔄 "Generating video..." (processing)
- ✅ Video ready (success)
- ❌ Video generation failed (error)

#### Stage 4: YouTube Upload (85% → 100%)
**Duration**: 1-2 minutes
**Process**:
- Video uploaded to YouTube
- Metadata and description added
- Thumbnail generated and uploaded
- Video set to public/scheduled

**Status Indicators**:
- 🔄 "Uploading to YouTube..." (processing)
- ✅ Complete! (success)
- ❌ Upload failed (error)

### Monitoring Progress

#### Real-time Updates
- Progress bars update every 2 seconds
- Status messages change based on current stage
- Time estimates provided for each stage
- Animated indicators show active processing

#### Progress Interpretation
- **10%**: Initial script generation
- **35%**: Script complete, audio starting
- **65%**: Audio complete, video starting
- **85%**: Video complete, upload starting
- **100%**: Fully processed and published

---

## Monitoring & Analytics

### Dashboard Analytics

#### Daily Statistics
- **Videos Created**: Count of completed videos
- **Success Rate**: Percentage of successful completions
- **Average Processing Time**: Time from start to finish
- **API Costs**: Total spending on OpenAI and ElevenLabs

#### Weekly Trends
- **Production Volume**: Videos per day over past week
- **Success Patterns**: Identify optimal processing times
- **Error Trends**: Track and analyze failure patterns

### Performance Metrics

#### Processing Times
- **Normal Range**: 7-12 minutes per video
- **Fast Processing**: 5-7 minutes (simple content)
- **Slow Processing**: 12-20 minutes (complex content)

#### Success Rates
- **Target Success Rate**: >90%
- **Good Performance**: 85-95%
- **Needs Attention**: <85%

#### Cost Tracking
- **Per Video Cost**: $0.10-0.20 average
- **Monthly Budget**: Track against limits
- **API Usage**: Monitor quota consumption

### Log Analysis

#### Accessing Logs
1. Click **"View Logs"** on dashboard
2. Navigate to `/dashboard/logs` directly
3. Check `log/production.log` for detailed information

#### Log Levels
- **INFO**: Normal processing updates
- **WARN**: Non-critical issues
- **ERROR**: Processing failures
- **DEBUG**: Detailed technical information

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Articles Stuck in "Pending" Status

**Symptoms**: Articles remain at 10% for extended periods

**Causes**:
- Background job worker not running
- API key issues
- Database connection problems

**Solutions**:
```bash
# Check if job worker is running
ps aux | grep solid_queue

# Restart job worker
bin/jobs

# Check API connectivity
rails console
> OpenAI::Client.new.models.list
```

#### 2. Script Generation Failures

**Symptoms**: Articles fail at 10-35% stage

**Common Causes**:
- Invalid OpenAI API key
- Rate limit exceeded
- Article content too long/short

**Solutions**:
1. Verify API key in `.env` file
2. Check OpenAI account usage and limits
3. Review article content length
4. Retry failed jobs from dashboard

#### 3. Audio Generation Issues

**Symptoms**: Articles fail at 35-65% stage

**Common Causes**:
- ElevenLabs API issues
- Script contains unsupported characters
- Voice ID not found

**Solutions**:
1. Check ElevenLabs API key and quota
2. Verify voice ID in configuration
3. Review script content for special characters
4. Test TTS with simple text

#### 4. Video Composition Failures

**Symptoms**: Articles fail at 65-85% stage

**Common Causes**:
- FFmpeg not installed or accessible
- Insufficient disk space
- Audio file corruption

**Solutions**:
```bash
# Check FFmpeg installation
ffmpeg -version

# Check disk space
df -h

# Verify audio file integrity
file storage/audio/article_123.mp3
```

#### 5. YouTube Upload Problems

**Symptoms**: Articles fail at 85-100% stage

**Common Causes**:
- YouTube API quota exceeded
- Invalid video format
- Authentication issues

**Solutions**:
1. Check YouTube API quota in Google Cloud Console
2. Verify video file format and size
3. Test YouTube API authentication
4. Review video content for policy violations

### Emergency Procedures

#### System Reset
If the system becomes unresponsive:
```bash
# Stop all processes
pkill -f rails
pkill -f solid_queue

# Clear temporary files
rm -rf tmp/pids/*
rm -rf tmp/cache/*

# Restart system
rails server -p 3000 &
bin/jobs &
```

#### Database Recovery
If database issues occur:
```bash
# Backup current database
cp db/development.sqlite3 db/backup_$(date +%Y%m%d_%H%M%S).sqlite3

# Reset database
rails db:drop db:create db:migrate db:schema:load:queue

# Restore from backup if needed
cp db/backup_YYYYMMDD_HHMMSS.sqlite3 db/development.sqlite3
```

---

## Advanced Configuration

### RSS Source Configuration

#### Adding New Sources
Edit `app/services/news_crawler_service.rb`:
```ruby
RSS_SOURCES = [
  'https://openai.com/blog/rss.xml',
  'https://www.anthropic.com/news/rss',
  'https://blog.google/technology/ai/rss/',
  'https://huggingface.co/blog/feed.xml',
  'https://your-new-source.com/rss.xml'  # Add new source
]
```

#### Source-specific Settings
Configure per-source processing rules:
```ruby
def process_source(url)
  case url
  when /openai/
    { priority: :high, language: :korean }
  when /anthropic/
    { priority: :medium, language: :korean }
  # Add custom rules
  end
end
```

### Script Generation Customization

#### Prompt Engineering
Modify script generation prompts in `app/services/script_generator_service.rb`:
```ruby
def generate_prompt(article)
  """
  Create an engaging Korean script for YouTube Shorts about this AI news:
  
  Title: #{article.title}
  Content: #{article.content}
  
  Requirements:
  - 30-40 seconds when spoken
  - Start with attention-grabbing hook
  - Include 3 key points
  - End with call-to-action
  - Use conversational Korean
  - Add relevant emojis
  
  Your custom requirements here...
  """
end
```

#### Voice and Tone Settings
Adjust script style parameters:
```ruby
SCRIPT_SETTINGS = {
  tone: :enthusiastic,        # :professional, :casual, :enthusiastic
  target_audience: :general,  # :technical, :general, :beginner
  length: :short,            # :short, :medium, :long
  include_emojis: true,
  include_hashtags: false
}
```

### Video Customization

#### Visual Settings
Modify video appearance in `app/services/video_generator_service.rb`:
```ruby
VIDEO_CONFIG = {
  resolution: '1080x1920',     # YouTube Shorts format
  framerate: 30,
  background_color: '#1a1a1a',
  text_color: '#ffffff',
  font_family: 'Arial',
  font_size: 48,
  animation_style: :slide_up   # :fade_in, :slide_up, :zoom_in
}
```

#### Branding Elements
Add your branding:
```ruby
def add_branding(video_path)
  # Add logo watermark
  # Add channel name
  # Add consistent color scheme
end
```

### Performance Optimization

#### Parallel Processing
Enable multiple concurrent jobs:
```ruby
# config/queue.yml
production:
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 5        # Increase for more concurrency
      processes: 3      # Multiple worker processes
```

#### Caching Strategy
Implement caching for better performance:
```ruby
# Cache API responses
Rails.cache.fetch("openai_response_#{article.id}", expires_in: 1.hour) do
  openai_client.generate_script(article.content)
end

# Cache generated assets
Rails.cache.fetch("video_#{article.id}", expires_in: 1.day) do
  generate_video(article)
end
```

---

## Best Practices

### Content Quality

#### Article Selection
- **Relevance**: Focus on breaking AI news and developments
- **Timeliness**: Process news within 24-48 hours of publication
- **Uniqueness**: Avoid duplicate or very similar content
- **Length**: Optimal article length: 200-1000 words

#### Script Quality
- **Hook Strength**: First 3 seconds are critical
- **Information Density**: Pack key insights into 30-40 seconds
- **Call-to-Action**: Include subscribe/like prompts
- **SEO Optimization**: Use relevant keywords naturally

### Operational Excellence

#### Monitoring Schedule
- **Hourly**: Check dashboard for stuck jobs
- **Daily**: Review success rates and error logs
- **Weekly**: Analyze performance trends and costs
- **Monthly**: Update API keys and review quotas

#### Maintenance Tasks
- **Daily**: Clear temporary files and logs
- **Weekly**: Database cleanup and optimization
- **Monthly**: Update dependencies and security patches
- **Quarterly**: Review and optimize processing pipeline

#### Backup Strategy
- **Database**: Daily automated backups
- **Generated Content**: Weekly archive to cloud storage
- **Configuration**: Version control for all settings
- **API Keys**: Secure backup of credentials

### Cost Optimization

#### API Usage
- **Batch Processing**: Group similar requests
- **Prompt Optimization**: Minimize token usage
- **Caching**: Avoid duplicate API calls
- **Rate Limiting**: Respect API quotas

#### Resource Management
- **Storage**: Regular cleanup of old video files
- **Memory**: Monitor worker memory usage
- **CPU**: Optimize video processing settings
- **Bandwidth**: Compress uploads when possible

### Quality Assurance

#### Content Review
- **Manual Spot Checks**: Review 10% of generated content
- **Automated Testing**: Validate script length and format
- **Performance Metrics**: Track view rates and engagement
- **User Feedback**: Monitor YouTube comments and analytics

#### Technical Validation
- **Unit Tests**: Test individual service components
- **Integration Tests**: Verify end-to-end pipeline
- **Performance Tests**: Monitor processing times
- **Security Audits**: Regular security reviews

---

## Support and Resources

### Getting Help

#### Documentation
- **README.md**: Quick start guide
- **MANUAL.md**: This comprehensive manual
- **TUTORIAL.md**: Step-by-step tutorial
- **API Documentation**: Service-specific guides

#### Community Support
- **GitHub Issues**: Report bugs and request features
- **Discussions**: Community Q&A and best practices
- **Wiki**: Extended documentation and examples

#### Professional Support
- **Email Support**: technical-support@ai-news-shorts.com
- **Priority Support**: Available for enterprise users
- **Custom Development**: Tailored solutions available

### Additional Resources

#### External Documentation
- **OpenAI API**: https://platform.openai.com/docs
- **ElevenLabs API**: https://docs.elevenlabs.io
- **YouTube Data API**: https://developers.google.com/youtube/v3
- **FFmpeg Documentation**: https://ffmpeg.org/documentation.html

#### Training Materials
- **Video Tutorials**: Step-by-step video guides
- **Webinars**: Live training sessions
- **Best Practices Guide**: Optimization techniques
- **Troubleshooting Database**: Common issues and solutions

---

**End of Manual**

*For the latest updates and additional resources, visit our documentation website.* 