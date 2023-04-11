#!/bin/bash
# v1.5
# empty_circle - 2023
# Scan_Central is a research tool designed to provide easy access to a variety of script scans.

# Func to check for valid IP
function is_valid_ip {
    local ip=$1
    local stat=1
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Func check hostname
function is_valid_hostname {
    local host=$1
    if [[ $host =~ ^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$ ]]; then
        return 0
    else
        return 1
    fi
}

# Base NMAP scan
function run_scan {
    local scan_type=$1
    local aggressive=$2
    local decoys="49.64.10.11,101.110.64.30,37.98.162.230"

    local script_name
    if [[ $aggressive == 1 ]]; then
        script_name="${scan_type}-*"
    else
        script_name="not intrusive and ${scan_type}-*"
    fi

    nmap -Pn -f --source-port 80 -D $decoys -T3 --scan-delay 50ms --max-scan-delay 125ms --script "$script_name" --spoof-mac $mac $tgt -oG $outfile
}


# Main program
function main {
    mac=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')
    echo "Welcome to the scanning tool"
    read -p "Enter the target IP or hostname: " tgt

    # Validate target input
    if ! is_valid_ip "$tgt" && ! is_valid_hostname "$tgt"; then
        echo "Invalid target input"
        exit 1
    fi

    read -p "Enter output file name (leave blank for no output file): " outfile

    # Validate output file name input
    if [[ -n $outfile && ! -w $(dirname "$outfile") ]]; then
        echo "Invalid output file name"
        exit 1
    fi

    scan_types=("http" "mssql" "pop3" "smb" "ftp" "sip" "ssh" "ajp")
    selection_index=1

    echo "Select a scan to run:"
    for scan_type in "${scan_types[@]}"; do
        echo "$selection_index) FULL ${scan_type} script scan (Safe)"
        echo "$((selection_index + 1))) FULL ${scan_type} script scan (Aggressive)"
        selection_index=$((selection_index + 2))
    done

    read -p "Enter selection: " selection

    if [[ $selection -lt 1 || $selection -gt $((selection_index - 1)) ]]; then
        echo "Invalid selection"
        exit 1
    fi

    scan_index=$(((selection - 1) / 2))
    aggressive=$((selection % 2))

    run_scan "${scan_types[$scan_index]}" "$aggressive"
}

# Call the main to start
main
