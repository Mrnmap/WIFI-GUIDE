#!/sh
sudo apt-get install aircrack-ng httrack ettercap iodine wireshark
mkdir 6_other_frameworks  && cd 6_other_frameworks
git clone https://github.com/wifiphisher/wifiphisher && cd wifiphisher && sudo python setup.py install && cd ..
wget https://raw.githubusercontent.com/ricardojoserf/awesome-wifi/master/scripts/wpa/pmkid_install.sh && sudo sh pmkid_install.sh && rm pmkid_install.sh
git clone https://github.com/ricardojoserf/WPA_Enterprise_Attack && cd WPA_Enterprise_Attack && sudo sh install.sh && cd ..
git clone https://github.com/DanMcInerney/wifijammer && cd wifijammer && sudo python setup.py install && cd ..
git clone https://github.com/Tylous/SniffAir && cd SniffAir && sudo ./setup.sh && cd ..
git clone https://github.com/P0cL4bs/WiFi-Pumpkin && cd WiFi-Pumpkin && sudo ./installer.sh --install && cd ..
git clone https://github.com/s0lst1c3/eaphammer && cd eaphammer && sudo ./kali-setup && cd ..
