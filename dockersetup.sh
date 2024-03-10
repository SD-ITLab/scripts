#!/bin/bash

# Function for printing colored section headings
print_colored_section_header() {
    echo
    echo -e "\e[1;34m#############################################\e[0m"
    echo
    echo -e "\e[1;34m  $1\e[0m"
    echo
    echo -e "\e[1;34m#############################################\e[0m"

    echo
}

# Function to execute commands with optional sudo
run_command() {
    if [ -x "$(command -v sudo)" ]; then
        sudo "$@"
    else
        "$@"
    fi
}

color_echo() {
    local color_code=$1
    shift
    echo -e "\e[1;${color_code}m$@\e[0m"
}

# Function to display installed services and ports
get_ip_address() {
    # Use the command "hostname -I" to obtain the IP address
    ip_address=$(hostname -I | awk '{print $1}')
    echo "$ip_address"
}

displaydocker() {
cat <<EOF
==========================================================================
        ____             __                _____      __                
       / __ \____  _____/ /_____  _____   / ___/___  / /___  ______     
      / / / / __ \/ ___/ //_/ _ \/ ___/   \__ \/ _ \/ __/ / / / __ \    
     / /_/ / /_/ / /__/ ,< /  __/ /      ___/ /  __/ /_/ /_/ / /_/ /    
    /_____/\____/\___/_/|_|\___/_/      /____/\___/\__/\__,_/ .___/     
                                                           /_/   
                           Created by: sd-itlab
==========================================================================
EOF
}

displayupdate() {
cat <<EOF
==========================================================================          
    _____            __                    __  __          __      __     
   / ___/__  _______/ /____  ____ ___     / / / /___  ____/ /___ _/ /____ 
   \__ \/ / / / ___/ __/ _ \/ __  __ \   / / / / __ \/ __  / __  / __/ _ \ 
  ___/ / /_/ (__  ) /_/  __/ / / / / /  / /_/ / /_/ / /_/ / /_/ / /_/  __/
 /____/\__  /____/\__/\___/_/ /_/ /_/   \____/  ___/\____/\____/\__/\___/ 
      /____/                                /_/                  
                           Created by: sd-itlab
==========================================================================
EOF
}


################################################################################################################
###############                                 System - Update                                  ###############
################################################################################################################
sys_update() {
    clear
    displayupdate
    run_command apt-get update 
    run_command apt-get upgrade -y
    clear
    displayupdate
    echo
    color_echo 32 "   System has been updated and brought up to date."
    echo
}



################################################################################################################
###############                              Docker - installation                               ###############
################################################################################################################
docker_setup() {
    clear
    displaydocker
    echo

    run_command apt-get install -y docker.io
    run_command apt-get install -y docker-compose
    run_command service docker stop

    # Check if /etc/docker directory exists
    if [ ! -d "/etc/docker" ]; then
        mkdir /etc/docker
    fi

    # Check if /etc/docker/daemon.json exists
    if [ ! -e "/etc/docker/daemon.json" ]; then
    # Change docker directory for more space
cat << EOL > /etc/docker/daemon.json
{
   "data-root": "/home/docker"
}
EOL
    fi

    # Check if /home/docker directory exists
    if [ ! -d "/home/docker" ]; then
        mkdir /home/docker
    fi

    # Check if /var/lib/docker directory exists
    if [ -d "/var/lib/docker" ]; then
        cp -rp /var/lib/docker/* "/home/docker/"
        rm -rf /var/lib/docker
    fi

    run_command service docker start
    clear
    displaydocker
    echo
    color_echo 32 "   Installation of Docker and Docker-Compose completed"
    echo
}



################################################################################################################
###############                            Dockerapps - installation                             ###############
################################################################################################################
app_menu() {
    # Function for managing users
    while true; do

        clear
        displaydocker
        # Show menu options
        echo
        echo -e "\e[1;33m   [1] Portainer\e[0m          [Dashboard for Docker-Containers]"     
        echo
        echo -e "\e[1;33m   [2] Adguard Home\e[0m       [Network-Adblocker]"
        echo
        echo -e "\e[1;33m   [3] Uptime Kuma\e[0m        [Uptime-Monitoring]"
        echo
        echo -e "\e[1;33m   [4] Watchtower\e[0m         [Autoupdate of Docker-Containers]"
        echo
        echo -e "\e[1;33m   [5] Grafana_Stack\e[0m      [Data visualization]"
        echo
        echo -e "\e[1;33m   [6] iVentoy\e[0m            [PXE-Server]"
        echo
        echo -e "\e[1;33m   [7] Heimdall\e[0m           [Custom-Dashboards for Favorites]"
        echo
        echo
        echo -e "\e[1;33m   [8] Return to the main menu\e[0m"
        echo
        echo "=========================================================================="
        echo

        # Query user input
        read -p "   Please select an option (1-8): " user_choice

        # Process menu options
        case $user_choice in
            1) install_portainer ;;
            2) install_adguard_home ;;
            3) install_uptime_kuma ;;
            4) install_watchtower ;;
            5) install_grafana_stack ;;
            6) install_iventoy ;;
            7) install_heimdall ;;
            8) return ;;
            *) echo "Invalid option. Please select again." ;;
        esac
    done
}



################################################################################################################
###############                                  Dockerapps                                      ###############
################################################################################################################

# Function to install portainer
install_portainer() {

    clear
    displaydocker
    echo
    print_colored_section_header "Install Portainer..."
    run_command docker volume create portainer_data
    run_command docker run -d -p 9000:9000 --hostname=portainer --name=portainer --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v portainer_data:/data \
        portainer/portainer-ce:latest
    clear
    displaydocker
    echo
    echo -e "   Portainer can now be reached at the following address > \e[32mhttp://$(get_ip_address):9000\e[0m"
    echo
    read -p "Press Enter to return to the menu."        
}

# function to install Adguard Home
install_adguard_home() {

    clear
    displaydocker
    echo    
    print_colored_section_header "Install Adguard Home..."
    run_command docker volume create adguardhome_data
    run_command docker run -d --hostname=adguardhome --name=adguardhome --restart=always \
        -v adguardhome_data:/opt/adguardhome/conf \
        -v adguardhome_data:/opt/adguardhome/work \
        -p 53:53/tcp \
        -p 53:53/udp \
        -p 33000:3000/tcp \
        -p 30080:80/tcp \
        adguard/adguardhome:latest
    clear
    displaydocker
    echo
    echo -e "   Adguard can now be reached at the following address > \e[32mhttp://$(get_ip_address):33000\e[0m / \e[32mhttp://$(get_ip_address):30080\e[0m"
    echo
    read -p "Press Enter to return to the menu."        
}

# function to install Uptime Kuma
install_uptime_kuma() {

    clear
    displaydocker
    echo    
    print_colored_section_header "Install Uptime Kuma..."
    run_command docker volume create uptimekuma_data
    run_command docker run -d --hostname=uptimekuma --name=uptimekuma --restart=always \
        -v uptimekuma_data:/app/data \
        -p 3001:3001 \
        louislam/uptime-kuma:latest
    clear
    displaydocker
    echo
    echo -e "   Uptime Kuma can now be reached at the following address > \e[32mhttp://$(get_ip_address):3001\e[0m"
    echo
    read -p "Press Enter to return to the menu."    
}

# function to install Watchtower
install_watchtower() {

    clear
    displaydocker
    echo    
    print_colored_section_header "Install Watchtower..."
    run_command docker run -d --hostname=watchtower --name=watchtower --restart=always \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /etc/localtime:/etc/localtime:ro \
        -e WATCHTOWER_NOTIFICATIONS=shoutrrr \
        -e WATCHTOWER_NOTIFICATION_URL= \
        -e WATCHTOWER_NOTIFICATIONS_LEVEL=info \
        -e WATCHTOWER_MONITOR_ONLY=false \
        -e WATCHTOWER_CLEANUP=true \
        -e WATCHTOWER_INCLUDE_STOPPED=true \
        -e WATCHTOWER_NO_STARTUP_MESSAGE=true \
        -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        -e WATCHTOWER_SCHEDULE="0 0 0 * * *" \
        -e WATCHTOWER_ROLLING_RESTART=true \
        containrrr/watchtower:latest
    clear
    displaydocker
    echo
    echo -e "   watchtower are now running"
    echo
    read -p "Press Enter to return to the menu."    
}

# Function to install Grafana and Node-exporter
install_grafana_stack() {

    clear
    displaydocker
    echo   
    print_colored_section_header "Install Grafana..."
    echo

    run_command mkdir -p /etc/prometheus/
cat <<EOL > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['node_exporter:9100']
EOL


	run_command docker network create grafana_network
	
	run_command docker volume create prometheus_data
    run_command docker run -d -p 9090:9090 --hostname=prometheus --name=prometheus --network=grafana_network --restart=unless-stopped \
        -v /etc/prometheus:/etc/prometheus \
        -v prometheus_data:/prometheus \
        prom/prometheus:latest

	run_command docker volume create grafana_data
    run_command docker run -d -p 3000:3000 --hostname=grafana --name=grafana --network=grafana_network --restart=unless-stopped \
        -v grafana-data:/var/lib/grafana \
        grafana/grafana:latest
		
    run_command docker run -d --hostname=node_exporter --name=node_exporter --network=grafana_network --restart=unless-stopped \
		--pid=host \
        -v /:/host:ro,rslave \
        quay.io/prometheus/node-exporter:v1.5.0 --path.rootfs=/host

    clear
    displaydocker
    echo   
    print_colored_section_header "Install Grafana..."
    echo
    read -p "Would you like to install the fritzbox-prometheus-exporter as well? (Y/N): " install_fritzbox_exporter

    if [ "$install_fritzbox_exporter" == "y" ]; then
        read -p "Enter the IP address of your Fritzbox: " fb_exporter_gateway_url
        read -p "Enter the fritzbox user name (USERNAME) for fritzbox-prometheus-exporter ein: " fb_exporter_username
        read -p "Enter the fritzbox password (PASSWORD) for fritzbox-prometheus-exporter ein: " fb_exporter_passwort
        echo
        run_command docker volume create fritzbox-prometheus-exporter_data
        run_command docker run -d -p 9042:9042 --hostname=fritzbox_exporter --name=fritzbox_exporter --network=grafana_network --restart=unless-stopped \
            -e USERNAME=$fb_exporter_username \
            -e PASSWORD=$fb_exporter_password \
            -e GATEWAY_URL=http://$fb_exporter_gateway_url:49000 \
            -e LISTEN_ADDRESS=0.0.0.0:9042 \
            mineyannik/fritzbox_exporter:latest

            fritzbox_exporter_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' fritzbox_exporter)

cat <<EOL >> /etc/prometheus/prometheus.yml

  - job_name: 'fritzbox_exporter'
    static_configs:
      - targets: ['$fritzbox_exporter_ip:9042']
EOL
        run_command docker restart prometheus
    else
        color_echo 31 "fritzbox-prometheus-exporter will be not installed"
    fi

    clear
    displaydocker
    echo
    echo -e "   Grafana can now be reached at the following address > \e[32mhttp://$(get_ip_address):3000\e[0m"
    echo -e "   Node-Exporter can now be reached at the following address > \e[32mhttp://$(get_ip_address):9090\e[0m"
    echo
    read -p "Press Enter to return to the menu."
}

install_iventoy(){
    clear
    displaydocker
    echo
    print_colored_section_header "Installiere iventoy"
    echo

    local_network=$(ip route | grep -oP 'src \K\S+' | head -n 1 | cut -d "." -f 1,2,3) 

    ufw allow from $local_network.0/24 to any port 67
    ufw allow from $local_network.0/24 to any port 68
    ufw allow from $local_network.0/24 to any port 69
    ufw allow from $local_network.0/24 to any port 26000
    ufw allow from $local_network.0/24 to any port 16000
    ufw allow from $local_network.0/24 to any port 10809
    run_command docker run -d --hostname=iventoy --name=iventoy --restart=always \
        --privileged \
        --network=host
        -v /home/iventoy/iso:/app/iso \
        -v /home/iventoy/log:/app/log \
        -v /home/iventoy/user:/app/user \
        ziggyds/iventoy:latest
    clear
    displaydocker
    echo
    echo -e "   iVentoy can now be reached at the following address > \e[32mhttp://$(get_ip_address):26000\e[0m"
    echo
    read -p "Press Enter to return to the menu."        
}

install_heimdall() {

    clear
    displaydocker
    echo
    print_colored_section_header "Installiere Heimdall"
    run_command docker volume create heimdall_data
    run_command docker run -d --hostname=heimdall --name=heimdall --restart=always \
        -v /heimdall/config:/app/config \
        -p 8080:80 \
        linuxserver/heimdall:latest
        clear
    displaydocker
    echo
    echo -e "   heimdall can now be reached at the following address > \e[32mhttp://$(get_ip_address):8080\e[0m"
    echo
    read -p "Press Enter to return to the menu."    
}

################################################################################################################
###############                                    Mainmenu                                      ###############
################################################################################################################
while true; do
    clear
    displaydocker
    # Process menu options
    echo
    echo -e "\e[1;33m   [1] Updating the system\e[0m     [Perform system update]"
    echo
    echo -e "\e[1;33m   [2] Install Docker\e[0m          [Install Docker and Docker-Compose]"
    echo
    echo -e "\e[1;33m   [3] Install Applications\e[0m    [Must have Docker-Apps]"
    echo
    echo
    echo -e "\e[1;33m   [4] Quit\e[0m"
    echo
    echo "=========================================================================="
    echo
    # Query user input
    read -p "   Please select an option (1-4): " choice

    # Process menu options
    case $choice in
        1) sys_update ; read -p "Press Enter to return to the main menu." ;;
        2) docker_setup ; read -p "Press Enter to return to the main menu." ;;
        3) app_menu ;;
        4)
            clear
            exit
            ;;
        *) ;;
    esac
done