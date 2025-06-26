# ⚡ AI News Shorts - Quick Start Guide

**Get your first AI-generated YouTube Short in 10 minutes!**

---

## 🚀 Super Quick Setup

### 1. Prerequisites (2 minutes)
```bash
# Check requirements
ruby --version  # Need 3.2.0
rails --version # Need 8.0.2
ffmpeg -version # Need for video processing
```

### 2. Get API Keys (3 minutes)
- **OpenAI**: [platform.openai.com](https://platform.openai.com) → API Keys → Create new
- **ElevenLabs**: [elevenlabs.io](https://elevenlabs.io) → Profile → API Keys → Generate
- **YouTube**: [console.cloud.google.com](https://console.cloud.google.com) → Enable YouTube Data API → Create API Key

### 3. Install & Configure (3 minutes)
```bash
# Clone and setup
git clone https://github.com/yourusername/ai-news-shorts.git
cd ai-news-shorts
bundle install

# Configure API keys
cp .env.example .env
# Edit .env with your API keys:
# OPENAI_API_KEY=sk-proj-your-key
# ELEVENLABS_API_KEY=sk_your-key
# YOUTUBE_API_KEY=AIzaSy-your-key

# Setup database
rails db:create db:migrate db:schema:load:queue
```

### 4. Start System (1 minute)
```bash
# Terminal 1: Rails server
rails server -p 3000

# Terminal 2: Background jobs
bin/jobs
```

### 5. Create First Video (1 minute)
1. Open `http://localhost:3000/dashboard`
2. Click **"Start Crawling"**
3. Wait for articles to appear
4. Watch progress bars fill to 100%
5. Your video is now on YouTube! 🎉

---

## 🎯 Essential Commands

```bash
# Start system
rails server -p 3000 &
bin/jobs &

# Check status
curl http://localhost:3000/dashboard/progress

# Manual crawl
curl -X POST http://localhost:3000/dashboard/start_crawling

# View logs
tail -f log/development.log
```

---

## 📊 Quick Dashboard Guide

### Status Indicators
- **10%**: 🤖 AI generating script
- **35%**: 🎙️ Creating voiceover
- **65%**: 🎬 Composing video
- **85%**: 📺 Uploading to YouTube
- **100%**: ✅ Live on YouTube!

### Key Metrics
- **Success Rate**: Aim for >90%
- **Processing Time**: 7-12 minutes per video
- **Daily Target**: 5-10 videos

---

## 🚨 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Stuck at 10% | Check OpenAI API key & billing |
| Stuck at 35% | Verify ElevenLabs key & quota |
| Stuck at 65% | Install FFmpeg: `brew install ffmpeg` |
| Stuck at 85% | Check YouTube API quota |
| Server won't start | Kill existing: `pkill -f rails` |
| Jobs not running | Restart: `bin/jobs` |

---

## 🎁 Quick Wins

### Day 1 Goals
- ✅ Generate 3-5 videos
- ✅ Achieve >80% success rate
- ✅ Understand dashboard basics

### Week 1 Goals
- ✅ 20-30 videos created
- ✅ >90% success rate
- ✅ Optimized posting schedule

### Month 1 Goals
- ✅ 200+ videos
- ✅ Growing YouTube channel
- ✅ Automated workflow

---

## 💡 Pro Tips

1. **Run crawling 3x daily** for fresh content
2. **Monitor success rates** - fix issues immediately
3. **Check YouTube Analytics** for best posting times
4. **Keep API keys funded** for uninterrupted service
5. **Backup your .env file** - you'll need it!

---

## 🔗 Quick Links

- **Dashboard**: `http://localhost:3000/dashboard`
- **Logs**: `http://localhost:3000/dashboard/logs`
- **Progress**: `http://localhost:3000/dashboard/progress`
- **Full Manual**: [MANUAL.md](MANUAL.md)
- **Tutorial**: [TUTORIAL.md](TUTORIAL.md)

---

**That's it! You're now generating AI videos automatically! 🚀**

*For detailed guides, troubleshooting, and advanced features, check out the full documentation.* 