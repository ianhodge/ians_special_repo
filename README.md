# Ian's Special Repo 🤠

Welcome to Code Country! The wildest repository in the west!

## What's This?

A fun Node.js web application that displays a horse meme with "Welcome to Code Country" text and a button that makes "YEEHAW!" appear on screen with animations.

## Features

- 🤠 Wild west themed UI
- 🐎 Horse meme image display
- 🎉 Interactive "Yeehaw" button with animations
- ✨ Sparkle effects and bouncing text
- 📱 Responsive design
- 🚀 Docker ready with multi-architecture support!
- 🔧 **Warp CLI included** - Use Warp agents from within the container

## Setup & Run

### Local Development
```bash
npm install
npm start
```

Visit `http://localhost:3000` to enter Code Country!

### Docker
```bash
docker build -t ians-special-repo .
docker run -p 3000:3000 ians-special-repo
```

### Using Warp CLI in the Container
🎉 **The Docker image now includes the real Warp CLI pre-installed!** 🎉

#### ✅ Ready to Use Warp CLI
```bash
# Run Warp CLI agent commands directly:
docker run --rm ihodge97/ians-special-repo:latest warp-cli agent run --prompt "List files in current directory"
docker run --rm ihodge97/ians-special-repo:latest warp-cli agent run --prompt "Show me the current directory"
docker run --rm ihodge97/ians-special-repo:latest warp-cli agent run --prompt "Create a new file called test.txt"

# Or use the shortcut (agent command maps to warp-cli agent):
docker run --rm ihodge97/ians-special-repo:latest agent run --prompt "Your command here"

# Check what's available:
docker run --rm ihodge97/ians-special-repo:latest warp-cli --help
docker run --rm ihodge97/ians-special-repo:latest warp-cli agent --help
```

#### 🚀 Running with Web App + CLI
```bash
# Start web app in background
docker run -d -p 3000:3000 --name code-country ihodge97/ians-special-repo:latest

# Use Warp CLI from the running container
docker exec code-country warp-cli agent run --prompt "List all files"
docker exec code-country agent run --prompt "Show current directory"

# Visit the web app
open http://localhost:3000
```

#### 🔑 Authentication
Note: Warp CLI requires authentication. In a remote environment, you'll need to:
1. Set up API keys or authentication as per Warp documentation
2. Or run `warp-cli login` if in an interactive environment

## Docker Hub
Image available at: `ihodge97/ians-special-repo:latest`

## File Structure
```
ians_special_repo/
├── package.json          # Node.js dependencies
├── server.js             # Express server
├── public/
│   └── index.html        # Main web page
├── assets/
│   └── horse-meme.jpg    # The legendary horse meme
├── Dockerfile            # Docker configuration
└── README.md            # You are here
```

## API Endpoints

- `GET /` - Main web page
- `GET /health` - Health check (returns yeehaw status)

Built with ❤️ and Node.js by Ian Hodge