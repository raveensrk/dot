#!/opt/homebrew/bin/bash

sudo apt-get update
# sudo apt-get upgrade
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get install -y $(xargs < "$1")
sudo apt-get install -y lftp=4.8.1-1ubuntu0.1 --allow-downgrades || echo -e "${YELLOW}LFTP install failed...${NC}"
