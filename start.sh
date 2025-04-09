#!/bin/bash

# Log startup
echo "Starting CasaOS Vercel DDNS updater..."

# Environment variable handling
if [ -n "$VERCEL_TOKEN" ] && [ -n "$DOMAIN_NAME" ]; then
  # Update the dns.config file with environment variables
  sed -i "s|VERCEL_TOKEN=\"\${VERCEL_TOKEN}\"|VERCEL_TOKEN=\"$VERCEL_TOKEN\"|g" /app/dns.config
  sed -i "s|DOMAIN_NAME=\"\${DOMAIN_NAME}\"|DOMAIN_NAME=\"$DOMAIN_NAME\"|g" /app/dns.config
  sed -i "s|SUBDOMAIN=\"\${SUBDOMAIN}\"|SUBDOMAIN=\"$SUBDOMAIN\"|g" /app/dns.config
  
  echo "Configuration updated with environment variables"
else
  echo "Warning: Missing environment variables. Please set VERCEL_TOKEN and DOMAIN_NAME."
fi

# Create log file if it doesn't exist
touch /var/log/dns-sync.log

# Run initial sync
echo "Performing initial DNS sync..."
/app/dns-sync.sh

# Start cron daemon in foreground
echo "Starting scheduled updates (every 15 minutes)..."
crond -f -d 8