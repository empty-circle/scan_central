#!/bin/bash
# empty_circle - 2023
# Scan_Central is a research tool designed to provide easy access to a variety of script scans.

# Function to check if a given string is a valid IP address
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

# Function to check if a given string is a valid hostname
function is_valid_hostname {
    local host=$1
    if [[ $host =~ ^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$ ]]; then
        return 0
    else
        return 1
    fi
}

# HTTP Script Execution
function http_scan {
    nmap --script "not intrusive and http-*" --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}

# MS-SQL Script Execution
function mssql_scan {
    nmap --script "not intrusive and ms-sql-*" --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}

# POP3 Script Execution
function pop3_scan {
    nmap --script "not intrusive and pop3-*" --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}

# sip SCript Execution
function sip_scan {
    nmap --script "not intrusive and sip-*" --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}
# smb Script
function smb_scan {
    nmap --script "not intrusive and smb-*" --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}
#ftp script
function ftp_scan {
    nmap -p 21 --script "not intrusive and ftp-*" --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}

#ssh
function ssh_scan {
    nmap -p 22 --script "not intrusive and ssh-*" --script-args 'ssh.usernames={"root", "user"}, publickeys={"./id_rsa1.pub", "./id_rsa2.pub"}' --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}

#aggressive SSH scan
function agg_ssh_scan {
    nmap -p 22 --script "ssh*" --script-args 'ssh.usernames={"root", "user"}, publickeys={"./id_rsa1.pub", "./id_rsa2.pub"}' --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}

#apj
function ajp_scan {
    nmap --script "not intrusive and ajp-*" --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}

#agg ftp script
function agg_ftp_scan {
    nmap -p 21 --script "ftp-*" --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}

#agg http scan
function agg_http_scan {
    nmap --script "http-*" --source-port 53 --spoof-mac $mac -T4 $tgt -oG $outfile
}

# Main program
ffunction main {
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

    echo "Select a scan to run:"
    echo "1) FULL http script scan"
    echo "2) FULL mssql script scan"
    echo "3) FULL pop3 script scan"
    echo "4) FULL smb script scan"
    echo "5) FULL ftp script scan"
    echo "6) FULL sip script scan"
    echo "7) FULL ssh script scan"
    echo "8) FULL ajp script scan"
    echo "9) AGG FULL ssh script scan"
    echo "10) AGG FULL ftp scan"
    echo "11) AGG FULL http scan"


    read -p "Enter selection: " selection

    case $selection in
        1)
            http_scan
            ;;
        2)
            mssql_scan
            ;;
        3)
            pop3_scan
            ;;
        4)
            smb_scan
            ;;
        5)
            ftp_scan
            ;;
        6)
            sip_scan
            ;;
        7)
            ssh_scan
            ;;
        8)
            ajp_scan
            ;;
        9)
            agg_ssh_scan
            ;;
        10)
            agg_ftp_scan
            ;;
        11)
            agg_http_scan
            ;;
        *)
            echo "Invalid selection"
            exit 1
            ;;
    esac
}

# Call the main function to start the program
main
