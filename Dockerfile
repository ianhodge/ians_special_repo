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

# Install Warp CLI directly from staging endpoint
# Using the staging download endpoint that supports direct DEB package downloads
RUN ARCH=$(dpkg --print-architecture) && \
    echo "Installing Warp CLI for architecture: $ARCH" && \
    # Map architecture names for the download URL
    case $ARCH in \
        amd64) TARGET_ARCH="amd64" ;; \
        arm64) TARGET_ARCH="arm64" ;; \
        *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    # Download the DEB package from staging endpoint
    curl -fsSL "https://staging.warp.dev/download/cli?os=linux&package=deb&channel=dev&arch=$TARGET_ARCH" -o /tmp/warp-cli.deb && \
    # Install the DEB package
    dpkg -i /tmp/warp-cli.deb && \
    # Clean up
    rm /tmp/warp-cli.deb && \
    echo "Warp CLI installed successfully from staging endpoint"

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

# Create symlink for easier access and update PATH
RUN ln -sf /usr/bin/warp-cli-dev /usr/local/bin/warp-cli || \
    ln -sf /opt/warpdotdev/warp-cli-dev/warp-dev /usr/local/bin/warp-cli

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
ENV WARP_API_KEY=wk-1.c8ade064a3e53f2cb41f41849c7d72a57be737edbd0bf331620739498a81301d

# Set entrypoint and default command
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []

# Add labels for better image management
LABEL maintainer="Ian Hodge <ihodge97@example.com>"
LABEL description="Ian's Special Repo - Welcome to Code Country! 🤠 (includes Warp CLI)"
LABEL version="3.0"
LABEL warp-cli="included"
