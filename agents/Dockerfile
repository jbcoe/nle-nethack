FROM python:3.12-slim

# Install essential packages 
RUN apt-get update && apt-get install -yq \
    apt-transport-https \
    bash-completion \
    bison \
    build-essential \
    curl \
    flex \
    git \
    libbz2-dev \
    ninja-build \
    sudo \
    vim \
    gnupg

# Install Node.js (required for Gemini CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Gemini CLI globally
RUN npm install -g @google/gemini-cli

# Create non-root user
RUN useradd -m -s /bin/bash vscode \
    && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && mkdir -p /workspace \
    && chown vscode:vscode /workspace \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Switch to non-root user
USER vscode

# Set up uv and Python environment
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set up environment variables
ENV PATH="/home/vscode/.local/bin:${PATH}"
ENV UV_PROJECT_ENVIRONMENT="/home/vscode/.venv"
ENV TERM="xterm-256color"
ENV COLORTERM="truecolor"

# Pre-configure Gemini CLI
RUN mkdir -p /home/vscode/.gemini \
    && echo '{"/workspace": "TRUST_FOLDER"}' > /home/vscode/.gemini/trustedFolders.json \
    && echo '{"security": {"auth": {"selectedType": "gemini-api-key"}}}' > /home/vscode/.gemini/settings.json
