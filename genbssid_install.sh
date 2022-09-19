#!/bin/sh

chmod +x genbssid.sh

./genbssid.sh

printf "#!/bin/sh /etc/rc.common\nSTART=100\nstart() {\n ./root/genbssid.sh\n}\n" > /etc/init.d/genbssid
chmod +x /etc/init.d/genbssid
/etc/init.d/genbssid enable

reboot