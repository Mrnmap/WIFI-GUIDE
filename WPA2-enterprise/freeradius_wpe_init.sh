#!/sh
sudo killall hostapd radiusd
sudo radiusd -X &
sudo airmon-ng check kill
cp files/ap.conf files/temp.conf
sed 's/SSID_name/'$1'/g' files/ap.conf > files/temp.conf
sudo hostapd files/temp.conf

