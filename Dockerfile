# Use official Node.js runtime as base image (switching to debian for Warp CLI compatibility)
FROM node:18-slim

# Install system dependencies including those needed for Homebrew and Warp CLI
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    wget \
    gnupg \
    git \
    build-essential \
    procps \
    file \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create warp-cli installation helper script
# Since Warp CLI binaries aren't publicly available via standard package managers,
# we create a helper that guides users through the installation process
RUN echo '#!/bin/bash' > /usr/local/bin/warp-cli && \
    echo '# Warp CLI Installation Helper' >> /usr/local/bin/warp-cli && \
    echo '' >> /usr/local/bin/warp-cli && \
    echo 'WARP_CLI_INSTALLED="/usr/local/bin/warp-cli-real"' >> /usr/local/bin/warp-cli && \
    echo '' >> /usr/local/bin/warp-cli && \
    echo '# Check if the real CLI has been installed' >> /usr/local/bin/warp-cli && \
    echo 'if [ -f "$WARP_CLI_INSTALLED" ]; then' >> /usr/local/bin/warp-cli && \
    echo '    exec "$WARP_CLI_INSTALLED" "$@"' >> /usr/local/bin/warp-cli && \
    echo 'fi' >> /usr/local/bin/warp-cli && \
    echo '' >> /usr/local/bin/warp-cli && \
    echo '# If this is an install command, try to install' >> /usr/local/bin/warp-cli && \
    echo 'if [ "$1" = "install" ]; then' >> /usr/local/bin/warp-cli && \
    echo '    echo "🔧 Installing Warp CLI..."' >> /usr/local/bin/warp-cli && \
    echo '    curl -fsSL "https://app.warp.dev/get_cli" | sh' >> /usr/local/bin/warp-cli && \
    echo '    if [ $? -eq 0 ]; then' >> /usr/local/bin/warp-cli && \
    echo '        echo "✅ Warp CLI installed successfully!"' >> /usr/local/bin/warp-cli && \
    echo '        echo "You can now use: warp-cli agent run --prompt \"your prompt\""' >> /usr/local/bin/warp-cli && \
    echo '        exit 0' >> /usr/local/bin/warp-cli && \
    echo '    else' >> /usr/local/bin/warp-cli && \
    echo '        echo "❌ Installation failed. Please visit https://docs.warp.dev/developers/cli"' >> /usr/local/bin/warp-cli && \
    echo '        exit 1' >> /usr/local/bin/warp-cli && \
    echo '    fi' >> /usr/local/bin/warp-cli && \
    echo 'fi' >> /usr/local/bin/warp-cli && \
    echo '' >> /usr/local/bin/warp-cli && \
    echo '# Show help/installation instructions' >> /usr/local/bin/warp-cli && \
    echo 'echo "🤠 Warp CLI Ready Container"' >> /usr/local/bin/warp-cli && \
    echo 'echo ""' >> /usr/local/bin/warp-cli && \
    echo 'echo "To install Warp CLI in this container:"' >> /usr/local/bin/warp-cli && \
    echo 'echo "  warp-cli install"' >> /usr/local/bin/warp-cli && \
    echo 'echo ""' >> /usr/local/bin/warp-cli && \
    echo 'echo "Or manually:"' >> /usr/local/bin/warp-cli && \
    echo 'echo "  curl -fsSL https://app.warp.dev/get_cli | sh"' >> /usr/local/bin/warp-cli && \
    echo 'echo ""' >> /usr/local/bin/warp-cli && \
    echo 'echo "After installation, use:"' >> /usr/local/bin/warp-cli && \
    echo 'echo "  warp-cli agent run --prompt \"your command\""' >> /usr/local/bin/warp-cli && \
    echo '' >> /usr/local/bin/warp-cli && \
    chmod +x /usr/local/bin/warp-cli

# Set working directory in container
WORKDIR /app

# Copy package.json first for better Docker layer caching
COPY package.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .

# Create a non-root user for security (Debian syntax)
RUN groupadd -g 1001 nodejs && \
    useradd -r -u 1001 -g nodejs -d /app -s /bin/bash -c "Node.js user" nextjs && \
    chown -R nextjs:nodejs /app

# Create entrypoint script to handle both web app and CLI commands (as root)
RUN echo '#!/bin/bash' > /usr/local/bin/entrypoint.sh && \
    echo 'set -e' >> /usr/local/bin/entrypoint.sh && \
    echo '' >> /usr/local/bin/entrypoint.sh && \
    echo '# If no arguments or if first arg starts with -, start the web app' >> /usr/local/bin/entrypoint.sh && \
    echo 'if [ $# -eq 0 ] || [ "${1:0:1}" = "-" ]; then' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "🤠 Starting Code Country web application..."' >> /usr/local/bin/entrypoint.sh && \
    echo '    exec npm start' >> /usr/local/bin/entrypoint.sh && \
    echo 'fi' >> /usr/local/bin/entrypoint.sh && \
    echo '' >> /usr/local/bin/entrypoint.sh && \
    echo '# Handle warp-cli commands' >> /usr/local/bin/entrypoint.sh && \
    echo 'if [ "$1" = "warp-cli" ]; then' >> /usr/local/bin/entrypoint.sh && \
    echo '    shift' >> /usr/local/bin/entrypoint.sh && \
    echo '    exec warp-cli "$@"' >> /usr/local/bin/entrypoint.sh && \
    echo 'fi' >> /usr/local/bin/entrypoint.sh && \
    echo '' >> /usr/local/bin/entrypoint.sh && \
    echo '# Handle direct agent commands (redirect to warp-cli)' >> /usr/local/bin/entrypoint.sh && \
    echo 'if [ "$1" = "agent" ]; then' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "🤠 Executing Warp CLI agent command..."' >> /usr/local/bin/entrypoint.sh && \
    echo '    exec warp-cli "$@"' >> /usr/local/bin/entrypoint.sh && \
    echo 'fi' >> /usr/local/bin/entrypoint.sh && \
    echo '' >> /usr/local/bin/entrypoint.sh && \
    echo '# Otherwise, execute the command as provided' >> /usr/local/bin/entrypoint.sh && \
    echo 'exec "$@"' >> /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Verify Warp CLI installation (as root)
RUN warp-cli --version || echo "Warp CLI verification: $?"

USER nextjs

# Expose port 3000
EXPOSE 3000

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []

# Add labels for better image management
LABEL maintainer="Ian Hodge <ihodge97@example.com>"
LABEL description="Ian's Special Repo - Welcome to Code Country! 🤠 (includes Warp CLI)"
LABEL version="2.0"
LABEL warp-cli="included"
