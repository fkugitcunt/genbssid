#!/bin/sh
macaddr_new=""
sedcommand=""
macaddr=""
vendor_macaddrs=""
vendor_macaddrs_count=0
macaddr_pattern="[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}"
full_macaddr_pattern="[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}"
config_file="/etc/config/wireless"
macaddress_db_file="macaddress-db.csv"
wireless_config=""

get_vendors_macaddrs()
{
        vendor_macaddrs=$(grep -i -E "^.*\(Asustek|Netgear|TP-Link.Technologies|Cisco.Systems|Netcomm|D-Link.International|Ubiquiti\).*2019.*$" < $macaddress_db_file | grep -o -E "^$macaddr_pattern")
        vendor_macaddrs_count=$(echo "$vendor_macaddrs" | grep -o -E "$macaddr_pattern" | grep -c '')
}

rand_bssid()
{
        macaddr=$(head -1 /dev/urandom | hexdump -e '1/1 "%02x"":"' | grep -m 1 -o -E "^$macaddr_pattern" | tr '[:lower:]' '[:upper:]')

        macaddr_new="9C:C9:EB:$macaddr" # default NETGEAR mac address to use

        random=$(awk "BEGIN{srand();print int(rand()*($((vendor_macaddrs_count))))}") # generate a random number from 1 to $vendor_macaddrs_count
        sleep 1 # sleep or pause for 1 second

        macaddr_new=$(printf "%s:$macaddr" $(echo "$vendor_macaddrs" | grep -o -E "$macaddr_pattern" | sed -n "$random p"))
}

clear_macaddr_options()
{
        wireless_config=$(grep -v -E "^.*option.*macaddr.*$" < $config_file) # invert select non matching lines from $config_file and save output to $wireless_config
}

run_script()
{
        ssids=$(echo "$wireless_config" | grep -E "^.*option.*ssid" | sed -e "s/^.*option.*ssid.*'\(.*\)'.*$/\1/g")
        set -- $ssids
        while [ -n "$1" ]; do
                rand_bssid # generate a new mac address

                sedcommand="s/^.*\(option.*ssid.*'$1'\).*$/\t\1\n\toption macaddr '$macaddr_new'/"
                wireless_config=$(echo "$wireless_config" | sed -e "$sedcommand")
                shift
        done

        echo "$wireless_config" > $config_file # save updated/modified config to $config_file
}

clear_macaddr_options
get_vendors_macaddrs

run_script
