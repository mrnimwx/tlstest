#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🗑️  Throughput Tester Uninstallation Script${NC}"
echo "============================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run as root (use sudo)${NC}"
    exit 1
fi

# Stop and disable service
if systemctl is-active --quiet throughput-test; then
    echo -e "${YELLOW}⏹️  Stopping throughput-test service...${NC}"
    systemctl stop throughput-test
fi

if systemctl is-enabled --quiet throughput-test; then
    echo -e "${YELLOW}🚫 Disabling throughput-test service...${NC}"
    systemctl disable throughput-test
fi

# Remove files
echo -e "${BLUE}🗑️  Removing files...${NC}"
rm -f /root/throughput_test.py
rm -f /etc/systemd/system/throughput-test.service

# Reload systemd
systemctl daemon-reload

echo -e "${GREEN}✅ Throughput tester uninstalled successfully!${NC}"