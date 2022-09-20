#!/bin/sh
macaddr_org=""
macaddr_new=""
sedcommand=""
my_ssid=""
bssid_macaddr_count=0
macaddr=""
vendor_macaddrs=""
count=0
count2=0
var1=""
random=0

rand_bssid()
{
        macaddr=$(head -1 /dev/urandom | hexdump -e '1/1 "%02x"":"' | grep -m 1 -o -E '^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}')

        macaddr_new="9c:c9:eb:$macaddr"

        for vendor in $(echo "Asustek|Netgear|TP-Link.Technologies|Cisco.Systems|Netcomm|D-Link.International|Ubiquiti" | sed s/\|/\\n/g )
        do
            vendor_macaddrs=$(cat macaddress-db.csv | grep -m 5 -i -E $(echo "^.*$vendor.*2019.*$") | grep -o -E '^[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}')
            set -- $vendor_macaddrs
            while [ -n "$1" ]; do
                if [ $count -eq 0 ]; then
                        var1="$1"
                else
                        var1="$var1 $1"
                fi
                count=$((count+1))
                shift
            done
        done

        for i in `seq 1 10`; do random=$(awk "BEGIN{srand();print int(rand()*($((count-1))-0)) }"); done

        set -- $(echo "$var1")
        while [ -n "$1" ]; do
                if [ $count2 -eq $random ]; then
                        # random vendors mac address reached
                        macaddr_new="$1:$macaddr"
                        break
                fi

                count2=$((count2+1))
                shift
        done
}
my_ssid="$@"
bssid_macaddr_count=$(cat /etc/config/wireless | egrep -o "[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+" | grep -c '')

if [ "$bssid_macaddr_count" -ge 1 ]; then
        if [ "$my_ssid" = "" ]; then
                macaddr_org=$(cat /etc/config/wireless | egrep -o "[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+:[0-9a-zA-Z]+")
                set -- $macaddr_org
                while [ -n "$1" ]; do
                        rand_bssid
                        sedcommand="s/$1/$macaddr_new/"
                        sed -i "$sedcommand" /etc/config/wireless
                        shift
                done
        else
                rand_bssid

                sedcommand="s/^.*\(option.*ssid.*'.*'\).*$/\t\1\n\toption macaddr '$macaddr_new'/"
                sed -i "$sedcommand" /etc/config/wireless
        fi
elif [ "$bssid_macaddr_count" -eq 0 ]; then
        if [ "$my_ssid" != "" ]; then
                rand_bssid

                sedcommand="s/^.*\(option.*ssid.*'$my_ssid'\).*$/\t\1\n\toption macaddr '$macaddr_new'/"
                sed -i "$sedcommand" /etc/config/wireless
        else
                ssids=$(cat /etc/config/wireless | grep -E "^.*option.*ssid" |  sed -e "s/^.*option.*ssid.*'\(.*\)'.*$/\1/g")
                set -- $ssids
                while [ -n "$1" ]; do
                        rand_bssid

                        sedcommand="s/^.*\(option.*ssid.*'$1'\).*$/\t\1\n\toption macaddr '$macaddr_new'/"
                        sed -i "$sedcommand" /etc/config/wireless
                        shift
                done
        fi
else
        echo "error: contact your admin; check for multiple `option macaddr` entry in config file; usage: ./genbssid.sh <ssid>"
fi
