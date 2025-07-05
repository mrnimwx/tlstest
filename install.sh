#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Throughput Tester Installation Script${NC}"
echo "==========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

# Check if certificate directory exists
if [ ! -d "/root/cert" ]; then
    echo -e "${RED}❌ Certificate directory /root/cert not found${NC}"
    echo -e "${YELLOW}💡 Please ensure your SSL certificates are in /root/cert/your-domain/fullchain.pem and privkey.pem${NC}"
    exit 1
fi

# Find domains
DOMAINS=$(find /root/cert -maxdepth 1 -type d ! -path /root/cert | wc -l)
if [ "$DOMAINS" -eq 0 ]; then
    echo -e "${RED}❌ No domain directories found in /root/cert/${NC}"
    exit 1
fi

DOMAIN_NAME=$(ls /root/cert | head -n1)
echo -e "${GREEN}✅ Found domain: $DOMAIN_NAME${NC}"

# Stop existing service if running
if systemctl is-active --quiet throughput-test; then
    echo -e "${YELLOW}⏹️  Stopping existing throughput-test service...${NC}"
    systemctl stop throughput-test
fi

# Copy files
echo -e "${BLUE}📁 Installing files...${NC}"
cp throughput_test.py /root/
chmod +x /root/throughput_test.py

cp throughput-test.service /etc/systemd/system/
chmod 644 /etc/systemd/system/throughput-test.service

# Reload systemd and enable service
echo -e "${BLUE}🔄 Configuring systemd service...${NC}"
systemctl daemon-reload
systemctl enable throughput-test

# Start service
echo -e "${BLUE}▶️  Starting throughput-test service...${NC}"
systemctl start throughput-test

# Wait a moment for service to start
sleep 2

# Check service status
if systemctl is-active --quiet throughput-test; then
    echo -e "${GREEN}✅ Throughput tester installed and running successfully!${NC}"
    echo ""
    echo -e "${BLUE}📊 Service Information:${NC}"
    echo "   - Service: throughput-test"
    echo "   - Port: 2020"
    echo "   - Domain: $DOMAIN_NAME"
    echo "   - Test URL: https://$DOMAIN_NAME:2020"
    echo ""
    echo -e "${BLUE}🔧 Useful Commands:${NC}"
    echo "   - Check status: systemctl status throughput-test"
    echo "   - View logs: journalctl -u throughput-test -f"
    echo "   - Restart: systemctl restart throughput-test"
    echo "   - Stop: systemctl stop throughput-test"
    echo ""
    echo -e "${BLUE}🧪 Test the service:${NC}"
    echo "   curl -I https://$DOMAIN_NAME:2020"
else
    echo -e "${RED}❌ Failed to start throughput-test service${NC}"
    echo -e "${YELLOW}🔍 Check logs with: journalctl -u throughput-test -n 20${NC}"
    exit 1
fi