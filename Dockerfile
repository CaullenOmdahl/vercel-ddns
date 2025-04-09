FROM alpine:latest

# Install required packages
RUN apk add --no-cache bash curl jq dcron

# Create app directory
WORKDIR /app

# Copy scripts and config
COPY dns-sync.sh /app/
COPY dns.config /app/
COPY start.sh /app/

# Make scripts executable
RUN chmod +x /app/dns-sync.sh /app/dns.config /app/start.sh

# Set up cron job to run every 15 minutes
RUN echo "*/15 * * * * /app/dns-sync.sh >> /var/log/dns-sync.log 2>&1" > /etc/crontabs/root

# Run the start script
CMD ["bash", "/app/start.sh"]