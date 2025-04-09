FROM alpine:latest

# Install required packages
RUN apk add --no-cache bash curl jq dcron

# Create app directory
WORKDIR /app

# Copy scripts
COPY dns-sync.sh /app/
COPY start.sh /app/

# Create template config file instead of copying it
RUN echo '#!/bin/bash\n\n# Get the token from https://vercel.com/account/tokens\nVERCEL_TOKEN="${VERCEL_TOKEN}"\n\n# Domain name (e.g. example.com)\nDOMAIN_NAME="${DOMAIN_NAME}"\n\n# Subdomain to update (note: use an empty string for the root record)\nSUBDOMAIN="${SUBDOMAIN}"' > /app/dns.config

# Make scripts executable
RUN chmod +x /app/dns-sync.sh /app/start.sh /app/dns.config

# Set up cron job to run every 15 minutes
RUN echo "*/15 * * * * /app/dns-sync.sh >> /var/log/dns-sync.log 2>&1" > /etc/crontabs/root

# Run the start script
CMD ["bash", "/app/start.sh"]