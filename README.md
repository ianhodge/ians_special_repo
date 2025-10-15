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
The Docker image includes the Warp CLI! You can use it like this:

```bash
# Start container with interactive shell
docker run -it -p 3000:3000 ihodge97/ians-special-repo:latest /bin/bash

# Inside the container, you can use warp-cli
warp-cli --version
warp-cli --help

# Or run warp-cli directly from docker run
docker run --rm ihodge97/ians-special-repo:latest warp-cli --version
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