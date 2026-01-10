#!/bin/bash
# Script to update DuckDNS domain with current public IP
# Usage: ./duckdns-update.sh YOUR_DOMAIN YOUR_TOKEN

DOMAIN=$1
TOKEN=$2

if [ -z "$DOMAIN" ] || [ -z "$TOKEN" ]; then
    echo "Usage: ./duckdns-update.sh YOUR_DOMAIN YOUR_TOKEN"
    exit 1
fi

PUBLIC_IP=$(curl -s https://api.ipify.org)
echo "Current public IP: $PUBLIC_IP"

# Update DuckDNS
curl -s "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=$PUBLIC_IP"

echo ""
echo "DuckDNS updated for domain: $DOMAIN.duckdns.org"
echo "Point your Kubernetes Ingress to this domain"
