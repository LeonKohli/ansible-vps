#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to format timestamp
format_timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get system stats
get_system_stats() {
    echo -e "${CYAN}=== System Statistics ===${NC}"
    echo -e "Timestamp: $(format_timestamp)"
    echo -e "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo -e "Memory Usage: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "Disk Usage: $(df -h / | awk 'NR==2 {print $5 " used"}')\n"
}

# Function to get detailed IP info
get_ip_info() {
    local ip="$1"
    local info=""
    
    if command_exists whois; then
        local asn
        asn=$(whois "$ip" 2>/dev/null | grep -i "origin" | head -n1 | awk '{print $2}')
        [ -n "$asn" ] && info="$info ASN: $asn"
    fi
    
    if command_exists geoiplookup; then
        local geo
        geo=$(geoiplookup "$ip" 2>/dev/null | head -n 1 | cut -d ':' -f 2-)
        [ -n "$geo" ] && info="$info Location: $geo"
    fi
    
    echo "$info"
}

echo -e "${BLUE}=== Fail2ban Status Overview ===${NC}"
echo -e "Report generated at: $(format_timestamp)\n"

# Get system stats
get_system_stats

# Get fail2ban version and status
f2b_version=$(fail2ban-client version | head -n1)
echo -e "${CYAN}Fail2ban Version: ${NC}$f2b_version"

# Get all jails
jails=$(fail2ban-client status | grep "Jail list:" | sed "s/^[^:]*:[ \t]*//g" | sed "s/,//g")
total_jails=$(echo "$jails" | wc -w)
total_banned=0

echo -e "\n${YELLOW}Active Jails ($total_jails):${NC}"
for jail in $jails
do
    # Get jail status with single fail2ban-client call to improve performance
    jail_status=$(fail2ban-client status "$jail")
    
    banned_count=$(echo "$jail_status" | grep "Currently banned:" | grep -o "[0-9]*")
    total_banned=$((total_banned + banned_count))
    total_banned_all=$(echo "$jail_status" | grep "Total banned:" | grep -o "[0-9]*")
    failed_count=$(echo "$jail_status" | grep "Currently failed:" | grep -o "[0-9]*")
    find_time=$(echo "$jail_status" | grep "findtime:" | grep -o "[0-9]*")
    max_retry=$(echo "$jail_status" | grep "maxretry:" | grep -o "[0-9]*")
    
    echo -e "\n${GREEN}[$jail]${NC}"
    echo -e "Currently banned IPs: ${RED}$banned_count${NC}"
    echo -e "Total banned IPs: ${RED}$total_banned_all${NC}"
    echo -e "Current failed attempts: ${YELLOW}$failed_count${NC}"
    echo -e "Find Time: ${CYAN}${find_time}s${NC}"
    echo -e "Max Retry: ${CYAN}$max_retry${NC}"
    
    # Get banned IP list with enhanced info
    banned_ips=$(echo "$jail_status" | grep "Banned IP list:" | sed "s/^[^:]*:[ \t]*//g")
    if [ -n "$banned_ips" ]; then
        echo -e "\nBanned IPs:"
        for ip in $banned_ips
        do
            ip_info=$(get_ip_info "$ip")
            echo -e "${RED}$ip${NC} - $ip_info"
        done
    fi
done

# Summary section
echo -e "\n${CYAN}=== Summary ===${NC}"
echo -e "Total Active Jails: $total_jails"
echo -e "Total Currently Banned IPs: ${RED}$total_banned${NC}"

# Show recent actions (both bans and unbans)
echo -e "\n${YELLOW}Recent Actions:${NC}"
journalctl -u fail2ban -n 15 --no-pager | grep -E "Ban|Unban" | tail -n 10

# Check fail2ban service status
echo -e "\n${CYAN}Service Status:${NC}"
systemctl status fail2ban --no-pager | grep "Active:"