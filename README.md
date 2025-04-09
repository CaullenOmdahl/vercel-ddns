# CasaOS Vercel DDNS Updater

A Docker-based Dynamic DNS updater for Vercel domains, optimized for CasaOS.

*Forked from [iam-medvedev/vercel-ddns](https://github.com/iam-medvedev/vercel-ddns)*

## Overview

This project automatically updates your Vercel DNS records with your server's current public IP address. It's specifically configured to work seamlessly with CasaOS, making it easy to keep your domain pointing to your home server even if your IP address changes.

## CasaOS Installation

1. Import the Docker Compose file through the CasaOS interface:
   - Go to "App Store" → "Custom" → "Import"
   - Copy and paste the contents of the docker-compose.yml file

2. Set your environment variables in the CasaOS UI:
   - `VERCEL_TOKEN`: Your Vercel API token (get it from https://vercel.com/account/tokens)
   - `DOMAIN_NAME`: Your domain name (e.g., example.com)
   - `SUBDOMAIN`: Subdomain to update (leave empty for root domain)

3. Start the container and verify it's running:
   - The service will automatically update your DNS records every 15 minutes
   - You can check the logs through the CasaOS interface

## Usage Notes

- The service will perform an initial DNS update when it starts
- Subsequent updates occur every 15 minutes via cron
- The container will automatically restart unless stopped manually
- Logs are available in the container at `/var/log/dns-sync.log`

## Manual Installation

If you prefer to run this outside of CasaOS:

1. Clone this repository:
   ```bash
   git clone https://github.com/CaullenOmdahl/casaos-vercel-ddns.git
   cd casaos-vercel-ddns
   ```

2. Create a `.env` file with your configuration:
   ```
   VERCEL_TOKEN=your_vercel_token
   DOMAIN_NAME=your-domain.com
   SUBDOMAIN=your-subdomain
   ```

3. Start with Docker Compose:
   ```bash
   docker-compose up -d
   ```

## Standalone Usage

For standalone usage without Docker:
# Creating
➜  ./dns-sync.sh
Updating IP: x.x.x.x
Record for SUBDOMAIN does not exist. Creating...
🎉 Done!

# Updating
➜  ./dns-sync.sh
Updating IP: x.x.x.x
Record for SUBDOMAIN already exists (id: rec_xxxxxxxxxxxxxxxxxxxxxxxx). Updating...
🎉 Done!
```

## Docker

There is a dockerized version of `vercel-ddns` with `CRON`.

Create 3 files in your directory:

1. `Dockerfile`.
2. `start.sh` - docker entry point
3. `dns.config` - configuration for `vercel-ddns`.

`Dockerfile`:

```dockerfile
FROM alpine:latest

WORKDIR /root

# Installing dependencies
RUN apk --no-cache add dcron curl jq bash
SHELL ["/bin/bash", "-c"]

# Cloning config and start file
COPY dns.config /root/dns.config
COPY start.sh /root/start.sh

# Cloning app
RUN curl -o /root/dns-sync.sh https://raw.githubusercontent.com/iam-medvedev/vercel-ddns/master/dns-sync.sh
RUN chmod +x /root/dns-sync.sh

# Setting up cron
RUN echo "*/30 * * * * /root/dns-sync.sh >> /var/log/dns-sync.log 2>&1" >> /etc/crontabs/root

# Starting
CMD ["bash", "/root/start.sh"]
```

`start.sh`:

```sh
# Performs the first sync and starts CRON
bash /root/dns-sync.sh && crond -f
```
