#!/sh

sudo files/hostapd_wpe/certs/bootstrap

cp files/hostapd_wpe/hostapd-wpe.conf files/hostapd_wpe/temp.conf
sed 's/SSID_name/'$1'/g' files/hostapd_wpe/hostapd-wpe.conf > files/hostapd_wpe/temp.conf
cd files/hostapd_wpe && sudo hostapd-wpe temp.conf

