#!/sh

sudo apt install aircrack-ng httrack ettercap
sudo rm -rf install
mkdir install 
cd install
mkdir 2_open
cd 2_open
mkdir captive_portals
cd captive_portals
mkdir fake_portal
cd fake_portal
git clone https://github.com/wifiphisher/wifiphisher
cd wifiphisher && sudo python setup.py install 
cd ..
cd ..
mkdir bypass_mac_spoofing
cd bypass_mac_spoofing
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/open/get_mac_ip.sh
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/open/change_mac_ip.sh
wget https://raw.githubusercontent.com/poliva/random-scripts/master/wifi/hotspot-bypass.sh -O poliva_auto_bypass.sh
cd ..
mkdir bypass_dns_tunnel
cd bypass_dns_tunnel
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/open/iodine_server.sh
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/open/iodine_client.sh
cd ..
cd ..
mkdir mitm_attack
cd mitm_attack
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/open/start_ettercap.sh
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/open/start_wireshark.sh
cd ..
cd ..

mkdir 3_wep
cd 3_wep
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wep_monitor.sh
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wep_attack.sh
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wep_crack.sh

cd ..
mkdir 4_wpa_psk
cd 4_wpa_psk
mkdir handshake
cd handshake
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wpa_monitor.sh
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wpa_attack.sh
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wpa_pyrit.sh
cd ..
mkdir pmkid
cd pmkid
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wpa/pmkid.sh
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wpa/script_pmkid.py
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wpa/pmkid_install.sh
sudo sh pmkid_install.sh
cd ..
cd ..
mkdir 5_wpa_enterprise
cd 5_wpa_enterprise
git clone https://github.com/ricardojoserf/WPA_Enterprise_Attack
cd WPA_Enterprise_Attack
sudo sh install.sh
cd ..
cd ..
mkdir 6_other
cd 6_other
cd jamming
git clone https://github.com/DanMcInerney/wifijammer
cd wifijammer
sudo python setup.py install
cd ..
git clone https://github.com/Tylous/SniffAir
cd SniffAir
sudo ./setup.sh
cd ..
git clone https://github.com/P0cL4bs/WiFi-Pumpkin
cd WiFi-Pumpkin
sudo ./installer.sh --install
cd ..
git clone https://github.com/s0lst1c3/eaphammer
cd eaphammer
sudo ./kali-setup
cd ..
cd ..