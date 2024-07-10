#!/bin/bash

# Funktion zur Überprüfung, ob ein Paket installiert ist
is_installed() {
    dpkg -l | grep -q $1
}

# Installiere Samba, falls noch nicht installiert
if ! is_installed samba; then
    echo "Samba ist nicht installiert. Installiere Samba..."
    sudo apt-get update
    sudo apt-get install -y samba
fi

# Funktion zur Erstellung der Gruppe sambashare, falls nicht vorhanden
create_sambashare_group() {
    if ! grep -q "^sambashare:" /etc/group; then
        echo "Erstelle Gruppe sambashare..."
        sudo groupadd sambashare
    else
        echo "Gruppe sambashare existiert bereits."
    fi
}

# Funktion zum Hinzufügen eines Samba-Benutzers
add_samba_user() {
    read -p "Geben Sie den Samba-Benutzernamen ein: " SAMBA_USER
    read -s -p "Geben Sie das Passwort für $SAMBA_USER ein: " SAMBA_PASS
    echo

    read -p "Geben Sie den Pfad für das Benutzerverzeichnis an (z.B. /home/mirror/samba/$SAMBA_USER): " USER_PATH

    # Erstelle das Benutzerverzeichnis
    sudo mkdir -p $USER_PATH
    sudo chown $SAMBA_USER:$SAMBA_USER $USER_PATH
    sudo chmod 0700 $USER_PATH

    # Benutzer hinzufügen und Passwort setzen
    sudo useradd -m -d $USER_PATH -s /sbin/nologin $SAMBA_USER
    echo -e "$SAMBA_PASS\n$SAMBA_PASS" | sudo smbpasswd -a $SAMBA_USER

    # Benutzer zur Gruppe sambashare hinzufügen
    sudo usermod -aG sambashare $SAMBA_USER

    # Home-Share zur smb.conf hinzufügen
    sudo bash -c "cat >> /etc/samba/smb.conf" <<EOL

[$SAMBA_USER]
   path = $USER_PATH
   valid users = $SAMBA_USER
   read only = no
   browsable = no
   create mask = 0700
   directory mask = 0700
EOL

    echo "Benutzer $SAMBA_USER wurde hinzugefügt und Benutzerverzeichnis erstellt."
    # Samba-Dienste neu starten
    echo "Starte Samba-Dienste neu..."
    sudo systemctl restart smbd
    sudo systemctl restart nmbd
}

# Funktion zum Entfernen eines Samba-Benutzers
delete_samba_user() {
    read -p "Geben Sie den Samba-Benutzernamen ein, den Sie entfernen möchten: " SAMBA_USER
    sudo smbpasswd -x $SAMBA_USER
    sudo userdel -r $SAMBA_USER

    # Entferne die Home-Share-Konfiguration aus smb.conf
    sudo sed -i "/\[$SAMBA_USER\]/,/^$/d" /etc/samba/smb.conf

    echo "Benutzer $SAMBA_USER wurde entfernt."
    # Samba-Dienste neu starten
    echo "Starte Samba-Dienste neu..."
    sudo systemctl restart smbd
    sudo systemctl restart nmbd
}

# Funktion zum Hinzufügen einer Samba-Freigabe für alle Benutzer
add_common_samba_share() {
    read -p "Geben Sie den Namen der Freigabe ein: " SHARE_NAME
    read -p "Geben Sie den Pfad zur Freigabe ein (z.B. /home/mirror/samba): " SHARE_PATH

    # Erstelle das Verzeichnis für die Freigabe, falls es nicht existiert
    if [ ! -d "$SHARE_PATH" ]; then
        echo "Erstelle Verzeichnis $SHARE_PATH..."
        sudo mkdir -p $SHARE_PATH
    fi

    # Setze die entsprechenden Berechtigungen für das Freigabeverzeichnis
    echo "Setze Berechtigungen für $SHARE_PATH..."
    sudo chown -R $USER:$USER $SHARE_PATH
    sudo chmod -R 0770 $SHARE_PATH

    # Freigabekonfiguration zur smb.conf hinzufügen
    echo "Füge Freigabekonfiguration zur smb.conf hinzu..."
    sudo bash -c "cat >> /etc/samba/smb.conf" <<EOL

[$SHARE_NAME]
   path = $SHARE_PATH
   valid users = @sambashare
   read only = no
   browsable = yes
   create mask = 0770
   directory mask = 0770
EOL

    # Samba-Dienste neu starten
    echo "Starte Samba-Dienste neu..."
    sudo systemctl restart smbd
    sudo systemctl restart nmbd

    echo "Freigabe $SHARE_NAME wurde hinzugefügt."
}

# Funktion zum Entfernen einer Samba-Freigabe
delete_samba_share() {
    read -p "Geben Sie den Namen der Freigabe ein, die Sie entfernen möchten: " SHARE_NAME

    # Entferne die Freigabekonfiguration aus smb.conf
    sudo sed -i "/\[$SHARE_NAME\]/,/^$/d" /etc/samba/smb.conf

    # Samba-Dienste neu starten
    echo "Starte Samba-Dienste neu..."
    sudo systemctl restart smbd
    sudo systemctl restart nmbd

    echo "Freigabe $SHARE_NAME wurde entfernt."
}

# Funktion zur Auflistung aller Samba-Benutzer
list_samba_users() {
    echo "Liste der Samba-Benutzer:"
    sudo pdbedit -L
}

# Hauptmenü
while true; do
    echo "=========================="
    echo "   Samba Verwaltung"
    echo "=========================="
    echo "1. Samba-Benutzer hinzufügen"
    echo "2. Samba-Benutzer entfernen"
    echo "3. Gemeinsame Samba-Freigabe hinzufügen"
    echo "4. Samba-Freigabe entfernen"
    echo "5. Liste der Samba-Benutzer anzeigen"
    echo "6. Beenden"
    read -p "Wählen Sie eine Option [1-6]: " option
    case $option in
        1) create_sambashare_group && add_samba_user ;;
        2) delete_samba_user ;;
        3) add_common_samba_share ;;
        4) delete_samba_share ;;
        5) list_samba_users ;;
        6) exit 0 ;;
        *) echo "Ungültige Option. Bitte wählen Sie eine Zahl zwischen 1 und 6." ;;
    esac
done
