#!/bin/bash
## dieses Skript dient zur statischen IPv4-Konfiguration der debian-vm
# Aktuelles Datum im Format JJJJMMTT_HHMMSS
CURRENT_DATE=$(date +"%Y%m%d_%H%M%S")

# Netzwerkeinstellungen
NETMASK="255.0.0.0"
GATEWAY="10.16.1.245"
DNS_SERVER="10.16.1.253"
INTERFACE_NAME="enp0s3"

# Benutzereingabe für Raumnummer und PC-Nummer
display() {
echo "####################################"
echo "     Virtualbox - Network Setup"
echo "####################################"
echo
}

clear
display
read -p "Geben Sie die Raumnummer ein: " RAUM_NUMMER
read -p "Geben Sie die PC-Nummer ein: " PC_NUMMER

# Überprüfen, ob die Eingaben numerisch sind
if ! [[ "$RAUM_NUMMER" =~ ^[0-9]+$ ]] || ! [[ "$PC_NUMMER" =~ ^[0-9]+$ ]]; then
    echo "Fehler: Raumnummer und PC-Nummer müssen numerisch sein."
    exit 1
fi

# IP-Adresse erstellen (192.168.raumnummer.pcnummer + 200)
IP_ADDRESS="10.16.$RAUM_NUMMER.$((PC_NUMMER + 200))"

# Netzwerkkonfiguration sichern
cp /etc/network/interfaces "/etc/network/interfaces_$CURRENT_DATE.backup"

# resolv.conf sichern
cp /etc/resolv.conf "/etc/resolv.conf_$CURRENT_DATE.backup"

# Netzwerkkonfiguration aktualisieren
cat <<EOL > /etc/network/interfaces
# Loopback-Schnittstelle
auto lo
iface lo inet loopback

# Die primäre Netzwerkschnittstelle
auto $INTERFACE_NAME
iface $INTERFACE_NAME inet static
    address $IP_ADDRESS
    netmask $NETMASK
    gateway $GATEWAY
EOL

# DNS-Konfiguration aktualisieren oder hinzufügen
if grep -q "nameserver" /etc/resolv.conf; then
    cp /etc/resolv.conf "/etc/resolv.conf_$CURRENT_DATE.backup"
    sed -i "s/nameserver.*/nameserver $DNS_SERVER/" /etc/resolv.conf
else
    echo "nameserver $DNS_SERVER" >> /etc/resolv.conf
fi

# Netzwerkschnittstelle neu starten
systemctl restart networking


clear
display
echo "Statische Netzwerkkonfiguration für IPv4 wurde aktualisiert. Backups erstellt: /etc/network/interfaces_$CURRENT_DATE.backup und /etc/resolv.conf_$CURRENT_DATE.backup"
