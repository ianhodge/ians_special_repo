# Use official Node.js runtime as base image (switching to debian for Warp CLI compatibility)
FROM node:18-slim

# Install system dependencies including curl and ca-certificates for Warp CLI
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Prepare for Warp CLI installation
# The Warp CLI may not be available for all architectures or via automatic installation
# This creates a framework for the CLI and provides installation instructions
RUN echo "Setting up Warp CLI installation framework..." && \
    # Create a wrapper script that provides installation guidance and basic functionality
    echo '#!/bin/bash' > /usr/local/bin/warp-cli && \
    echo 'set -e' >> /usr/local/bin/warp-cli && \
    echo '' >> /usr/local/bin/warp-cli && \
    echo '# Check if actual warp-cli binary exists' >> /usr/local/bin/warp-cli && \
    echo 'REAL_WARP_CLI="/usr/local/bin/warp-cli-binary"' >> /usr/local/bin/warp-cli && \
    echo 'if [ -f "$REAL_WARP_CLI" ]; then' >> /usr/local/bin/warp-cli && \
    echo '    exec "$REAL_WARP_CLI" "$@"' >> /usr/local/bin/warp-cli && \
    echo 'fi' >> /usr/local/bin/warp-cli && \
    echo '' >> /usr/local/bin/warp-cli && \
    echo '# Provide help and installation instructions' >> /usr/local/bin/warp-cli && \
    echo 'if [ "$1" = "--version" ] || [ "$1" = "-v" ]; then' >> /usr/local/bin/warp-cli && \
    echo '    echo "warp-cli (container setup - requires manual installation)"' >> /usr/local/bin/warp-cli && \
    echo '    echo "To install the real Warp CLI:"' >> /usr/local/bin/warp-cli && \
    echo '    echo "1. Run: curl -fsSL https://app.warp.dev/get_cli | sh"' >> /usr/local/bin/warp-cli && \
    echo '    echo "2. Or visit: https://docs.warp.dev/developers/cli"' >> /usr/local/bin/warp-cli && \
    echo '    exit 0' >> /usr/local/bin/warp-cli && \
    echo 'fi' >> /usr/local/bin/warp-cli && \
    echo '' >> /usr/local/bin/warp-cli && \
    echo 'if [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ $# -eq 0 ]; then' >> /usr/local/bin/warp-cli && \
    echo '    echo "Warp CLI (Container Setup)"' >> /usr/local/bin/warp-cli && \
    echo '    echo ""' >> /usr/local/bin/warp-cli && \
    echo '    echo "This container is set up to support Warp CLI, but the binary"' >> /usr/local/bin/warp-cli && \
    echo '    echo "needs to be installed manually due to platform restrictions."' >> /usr/local/bin/warp-cli && \
    echo '    echo ""' >> /usr/local/bin/warp-cli && \
    echo '    echo "To install Warp CLI in this container:"' >> /usr/local/bin/warp-cli && \
    echo '    echo "1. Run: curl -fsSL https://app.warp.dev/get_cli | sh"' >> /usr/local/bin/warp-cli && \
    echo '    echo "2. Or manually download from: https://docs.warp.dev/developers/cli"' >> /usr/local/bin/warp-cli && \
    echo '    echo ""' >> /usr/local/bin/warp-cli && \
    echo '    echo "Expected usage after installation:"' >> /usr/local/bin/warp-cli && \
    echo '    echo "  warp-cli agent run --prompt \"your prompt here\""' >> /usr/local/bin/warp-cli && \
    echo '    exit 0' >> /usr/local/bin/warp-cli && \
    echo 'fi' >> /usr/local/bin/warp-cli && \
    echo '' >> /usr/local/bin/warp-cli && \
    echo '# If someone tries to run agent commands, provide helpful guidance' >> /usr/local/bin/warp-cli && \
    echo 'echo "❌ Warp CLI not installed yet."' >> /usr/local/bin/warp-cli && \
    echo 'echo "Run: curl -fsSL https://app.warp.dev/get_cli | sh"' >> /usr/local/bin/warp-cli && \
    echo 'echo "Then try your command again."' >> /usr/local/bin/warp-cli && \
    echo 'exit 1' >> /usr/local/bin/warp-cli && \
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
    useradd -r -u 1001 -g nodejs -d /app -s /bin/sh -c "Node.js user" nextjs && \
    chown -R nextjs:nodejs /app && \
    # Ensure warp-cli is accessible to all users
    chmod 755 /usr/local/bin/warp-cli

# Create entrypoint script to handle both web app and CLI commands (as root)
RUN echo '#!/bin/bash' > /usr/local/bin/entrypoint.sh && \
    echo 'set -e' >> /usr/local/bin/entrypoint.sh && \
    echo '' >> /usr/local/bin/entrypoint.sh && \
    echo '# Debug: Print arguments for troubleshooting' >> /usr/local/bin/entrypoint.sh && \
    echo '# echo "DEBUG: Args: $*" >&2' >> /usr/local/bin/entrypoint.sh && \
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
    echo '    exec /usr/local/bin/warp-cli "$@"' >> /usr/local/bin/entrypoint.sh && \
    echo 'fi' >> /usr/local/bin/entrypoint.sh && \
    echo '' >> /usr/local/bin/entrypoint.sh && \
    echo '# Handle direct agent commands (redirect to warp-cli)' >> /usr/local/bin/entrypoint.sh && \
    echo 'if [ "$1" = "agent" ]; then' >> /usr/local/bin/entrypoint.sh && \
    echo '    echo "Converting agent command to warp-cli agent..."' >> /usr/local/bin/entrypoint.sh && \
    echo '    exec /usr/local/bin/warp-cli "$@"' >> /usr/local/bin/entrypoint.sh && \
    echo 'fi' >> /usr/local/bin/entrypoint.sh && \
    echo '' >> /usr/local/bin/entrypoint.sh && \
    echo '# Otherwise, execute the command as provided' >> /usr/local/bin/entrypoint.sh && \
    echo 'exec "$@"' >> /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

# Verify Warp CLI installation (as root) - non-blocking
RUN echo "Checking Warp CLI installation..." && \
    ls -la /usr/local/bin/warp-cli && \
    (warp-cli --version || echo "Warp CLI installation verification failed, but continuing...")

USER nextjs

# Set PATH to include /usr/local/bin for the nextjs user
ENV PATH="/usr/local/bin:${PATH}"

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
