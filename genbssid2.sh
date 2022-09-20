#!/bin/sh
macaddr_org=""
macaddr_new=""
sedcommand=""
my_ssid=""
bssid_macaddr_count=0

rand_bssid()
{
        macaddr=$(head -1 /dev/urandom | hexdump -e '1/1 "%02x"":"' | grep -m 1 -o -E '^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}')
        #macaddr_new="9c:c9:eb:$macaddr"

        count=0
        var1=""

        for vendor in $(echo "Asustek|Netgear|TP-Link.Technologies|Cisco.Systems|Netcomm|D-Link.International|Ubiquiti" | sed s/\|/\\n/g )
        do
            i=$(cat macaddress-db.csv | grep -m 5 -i -E $(echo "^.*$vendor.*2019.*$") | grep -o -E '^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}')
            set -- $i
            while [ -n "$1" ]; do
                var1="$var1 $1"
                #printf '%s\n' "$1"
                count=$((count+1))
                shift
            done
        done

        count2=0
        random=$(awk "BEGIN{srand();print int(rand()*($((count-1))-0)) }")
        #echo $random

        for x in $(echo $var1)
        do
            if [ $count2 -eq $random ]; then
                #printf '%s' "$x"
                macaddr_new="$x:$macaddr"
            fi
            count2=$((count2+1))
        done
}

my_ssid="$@"

bssid_macaddr_count=$(cat /etc/config/wireless | egrep -o "[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+" | grep -c '')

if [ $bssid_macaddr_count -ge 1 ]; then
        if [[ "$my_ssid" == "" ]]; then
                macaddr_org=$(cat /etc/config/wireless | egrep -o "[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+")
                set -- $macaddr_org
                while [ -n "$1" ]; do
                        rand_bssid
                        sed -i "s/$1/$macaddr_new/" /etc/config/wireless
                        shift
                done
        else
                rand_bssid
                sed -i "s/option ssid '$my_ssid'/option ssid '$my_ssid'\n\toption macaddr '$macaddr_new'/" /etc/config/wireless
        fi
elif [ $bssid_macaddr_count -eq 0 ]; then
        if [[ "$my_ssid" != "" ]]; then
                rand_bssid
                sed -i "s/option ssid '$my_ssid'/option ssid '$my_ssid'\n\toption macaddr '$macaddr_new'/" /etc/config/wireless
        else
                ssids=$(cat /etc/config/wireless | grep "option ssid" | sed -e "s/^\toption ssid '\(.*\)'$/\1/g")
                set -- $ssids
                while [ -n "$1" ]; do
                        rand_bssid
                        sed -i "s/\(option ssid '$1'\)$/\1\n\toption macaddr '$macaddr_new'/" /etc/config/wireless
                        shift
                done
        fi
else
        echo "error: contact your admin; check for multiple `option macaddr` entry in config file; usage: ./genbssid.sh <ssid>"
fi
