#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Fail2ban Status Overview ===${NC}\n"

# Get all jails
JAILS=$(fail2ban-client status | grep "Jail list:" | sed "s/^[^:]*:[ \t]*//g" | sed "s/,//g")

# Print overall status
echo -e "${YELLOW}Active Jails:${NC}"
for JAIL in $JAILS
do
    BANNED_COUNT=$(fail2ban-client status "$JAIL" | grep "Currently banned:" | grep -o "[0-9]*")
    TOTAL_BANNED=$(fail2ban-client status "$JAIL" | grep "Total banned:" | grep -o "[0-9]*")
    FAILED_COUNT=$(fail2ban-client status "$JAIL" | grep "Currently failed:" | grep -o "[0-9]*")
    
    echo -e "\n${GREEN}[$JAIL]${NC}"
    echo -e "Currently banned IPs: ${RED}$BANNED_COUNT${NC}"
    echo -e "Total banned IPs: ${RED}$TOTAL_BANNED${NC}"
    echo -e "Current failed attempts: ${YELLOW}$FAILED_COUNT${NC}"
    
    # Get banned IP list
    BANNED_IPS=$(fail2ban-client status "$JAIL" | grep "Banned IP list:" | sed "s/^[^:]*:[ \t]*//g")
    if [ ! -z "$BANNED_IPS" ]; then
        echo -e "\nBanned IPs:"
        for IP in $BANNED_IPS
        do
            # Try to get geolocation info
            if command -v geoiplookup >/dev/null 2>&1; then
                GEO=$(geoiplookup "$IP" 2>/dev/null | head -n 1 | cut -d ':' -f 2-)
                echo -e "${RED}$IP${NC} - $GEO"
            else
                echo -e "${RED}$IP${NC}"
            fi
        done
    fi
done

# Show recent failed attempts
echo -e "\n${YELLOW}Recent Failed Attempts:${NC}"
journalctl -u fail2ban -n 10 --no-pager | grep "Ban" | tail -n 5 