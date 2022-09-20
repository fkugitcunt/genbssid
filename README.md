# genbssid

To install copy and paste the following single line command,
__________________________________________________________
opkg update; opkg list-upgradable | cut -f 1 -d ' ' | xargs -r opkg upgrade; opkg install wget-ssl curl nano coreutils-tr; wget https://github.com/fkugitcunt/genbssid/raw/main/genbssid_install.sh -O genbssid_install.sh; chmod +x genbssid_install.sh; ./genbssid_install.sh
__________________________________________________________

To validate the generated BSSID mac address

Visit the following URL http://sqa.fyicenter.com/1000208_MAC_Address_Validator.html to 

or use the following curl command in /bin/bash shell
____________________________________________________________
curl -s -d "Query=6C-B1-58-E0-23-64&Submit=Validate" -X POST http://sqa.fyicenter.com/1000208_MAC_Address_Validator.html#Result | grep -o -E "\\">Valid|\\">Invalid" | grep -o -E 'Valid|Invalid'
___________________________________________________________


Good script checker website. https://www.shellcheck.net
