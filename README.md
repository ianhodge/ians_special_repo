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
The Docker image is set up to support Warp CLI, but requires manual installation:

#### Step 1: Install Warp CLI in the container
```bash
# Start the container with shell access
docker run -it -p 3000:3000 ihodge97/ians-special-repo:latest /bin/sh

# Inside the container, install Warp CLI:
curl -fsSL https://app.warp.dev/get_cli | sh

# Or use the wrapper to see installation instructions:
warp-cli --help
```

#### Step 2: Use Warp CLI for agent operations
```bash
# After installation, you can run agent commands:
warp-cli agent run --prompt "List files in current directory"
warp-cli agent run --prompt "Show me the current directory"
warp-cli agent run --prompt "Create a new file called test.txt"

# Or from outside the container (after installing CLI inside):
docker exec <container-name> warp-cli agent run --prompt "Your command here"
```

#### Alternative: Pre-install in custom image
```dockerfile
# Build your own image with Warp CLI pre-installed
FROM ihodge97/ians-special-repo:latest
USER root
RUN curl -fsSL https://app.warp.dev/get_cli | sh
USER nextjs
```

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