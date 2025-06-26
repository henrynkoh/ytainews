# 🚀 AI News Shorts Generator

**Transform AI/LLM news articles into viral YouTube Shorts automatically!**

[![Rails](https://img.shields.io/badge/Rails-8.0.2-red.svg)](https://rubyonrails.org/)
[![Ruby](https://img.shields.io/badge/Ruby-3.2.0-red.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 🎯 What is AI News Shorts?

AI News Shorts is a fully automated system that converts AI and LLM news articles into engaging Korean YouTube Shorts videos. It crawls news from major AI companies, generates compelling scripts using GPT-4, creates professional voiceovers with ElevenLabs TTS, composes videos with FFmpeg, and automatically uploads them to YouTube.

## ✨ Key Features

### 🤖 **Complete AI Pipeline**
- **RSS News Crawling**: Automatically fetches latest AI news from OpenAI, Anthropic, Google AI, and Hugging Face
- **AI Script Generation**: GPT-4 powered Korean script writing optimized for YouTube Shorts (30-40 seconds)
- **Professional Audio**: ElevenLabs TTS creates high-quality Korean voiceovers
- **Video Composition**: FFmpeg generates engaging videos with animated backgrounds and text overlays
- **Auto YouTube Upload**: Seamless publishing with optimized metadata and thumbnails

### 📊 **Beautiful Dashboard**
- Real-time progress tracking with animated progress bars
- Live analytics: Today's videos, total views, success rates
- Failed job monitoring with retry functionality
- Manual trigger controls for crawling and processing

### 🔄 **Background Processing**
- Solid Queue for reliable job processing
- Automatic retry mechanisms for failed operations
- Scalable architecture supporting multiple concurrent videos

### 📈 **Analytics & Monitoring**
- Comprehensive logging system
- Cost tracking for API usage
- Performance metrics and success rates
- Daily/weekly statistics visualization

## 🛠️ Technology Stack

- **Backend**: Ruby on Rails 8.0.2
- **Database**: SQLite with Solid Queue
- **AI Services**: OpenAI GPT-4, ElevenLabs TTS
- **Video Processing**: FFmpeg
- **Cloud APIs**: YouTube Data API v3
- **Frontend**: Tailwind CSS, Stimulus.js
- **Job Processing**: Solid Queue

## 📋 Prerequisites

- **Ruby 3.2.0** (managed with rbenv)
- **Rails 8.0.2**
- **FFmpeg** (for video processing)
- **API Keys**:
  - OpenAI API Key
  - ElevenLabs API Key
  - YouTube Data API v3 Key

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/ai-news-shorts.git
cd ai-news-shorts
```

### 2. Install Dependencies
```bash
# Install Ruby 3.2.0 with rbenv
rbenv install 3.2.0
rbenv use 3.2.0

# Install gems
bundle install

# Install FFmpeg
brew install ffmpeg  # macOS
# sudo apt-get install ffmpeg  # Ubuntu
```

### 3. Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Edit .env with your API keys
nano .env
```

Required environment variables:
```env
OPENAI_API_KEY=your_openai_api_key_here
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
YOUTUBE_API_KEY=your_youtube_api_key_here
```

### 4. Database Setup
```bash
# Create and migrate database
rails db:create
rails db:migrate
rails db:schema:load:queue

# Seed initial data (optional)
rails db:seed
```

### 5. Start the Application
```bash
# Start Rails server
rails server -p 3000

# Start background job worker (in separate terminal)
bin/jobs
```

### 6. Access the Dashboard
Open your browser and navigate to: `http://localhost:3000/dashboard`

## 📖 Usage Guide

### Basic Operation

1. **Start News Crawling**: Click "Start Crawling" to fetch latest AI news
2. **Monitor Progress**: Watch real-time progress bars for each video
3. **View Analytics**: Check dashboard for success rates and statistics
4. **Manual Processing**: Trigger individual steps if needed

### Progress Tracking

The system provides detailed progress tracking:
- **10%**: Script generation (1-2 minutes)
- **35%**: Audio creation (2-3 minutes)
- **65%**: Video composition (3-4 minutes)
- **85%**: YouTube upload (1-2 minutes)
- **100%**: Complete and published

### Monitoring

- **Dashboard**: Real-time overview of all operations
- **Logs**: Detailed logging for debugging and monitoring
- **Analytics**: Performance metrics and cost tracking

## 🏗️ Architecture

### Core Components

1. **News Crawler Service**: Fetches articles from RSS feeds
2. **Script Generator Service**: Creates engaging Korean scripts
3. **Audio Generator Service**: Produces high-quality voiceovers
4. **Video Generator Service**: Composes final video content
5. **YouTube Uploader Service**: Publishes to YouTube with metadata

### Database Schema

- **news_articles**: Stores article content, processing status, and metadata
- **generation_logs**: Tracks processing steps and errors
- **solid_queue_***: Background job management tables

### Job Processing Flow

```
RSS Feeds → News Crawler → Script Generator → Audio Generator → Video Generator → YouTube Uploader
```

## 🔧 Configuration

### API Configuration

Edit `.env` file with your API credentials:

```env
# OpenAI Configuration
OPENAI_API_KEY=sk-proj-your-key-here
OPENAI_MODEL=gpt-4

# ElevenLabs Configuration
ELEVENLABS_API_KEY=sk_your-key-here
ELEVENLABS_VOICE_ID=your-voice-id

# YouTube Configuration
YOUTUBE_API_KEY=AIzaSy-your-key-here
YOUTUBE_CHANNEL_ID=your-channel-id
```

### RSS Sources

Default news sources (configurable in `app/services/news_crawler_service.rb`):
- OpenAI Blog RSS
- Anthropic News RSS
- Google AI Blog RSS
- Hugging Face Blog RSS

## 🚨 Troubleshooting

### Common Issues

**1. Solid Queue Tables Missing**
```bash
rails db:schema:load:queue
```

**2. FFmpeg Not Found**
```bash
brew install ffmpeg  # macOS
sudo apt-get install ffmpeg  # Ubuntu
```

**3. API Key Errors**
- Verify API keys in `.env` file
- Check API key permissions and quotas
- Ensure correct environment variable names

**4. Background Jobs Not Processing**
```bash
# Restart job worker
bin/jobs
```

### Debug Mode

Enable detailed logging:
```bash
RAILS_LOG_LEVEL=debug rails server
```

## 📊 Performance

### Expected Processing Times
- **News Crawling**: 30-60 seconds
- **Script Generation**: 1-2 minutes per article
- **Audio Generation**: 2-3 minutes per article
- **Video Composition**: 3-4 minutes per article
- **YouTube Upload**: 1-2 minutes per article

### Resource Usage
- **Memory**: 512MB - 1GB per worker
- **Storage**: ~50MB per generated video
- **API Costs**: ~$0.10-0.20 per video (OpenAI + ElevenLabs)

## 🔒 Security

- API keys stored in environment variables
- Input validation for all user inputs
- Rate limiting for API calls
- Secure file handling for generated content

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenAI** for GPT-4 API
- **ElevenLabs** for TTS technology
- **YouTube** for video hosting platform
- **Rails Community** for the amazing framework

## 📞 Support

- **Documentation**: [Wiki](https://github.com/yourusername/ai-news-shorts/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/ai-news-shorts/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/ai-news-shorts/discussions)

---

**Made with ❤️ for the AI community**

*Transform AI news into viral content automatically!* 