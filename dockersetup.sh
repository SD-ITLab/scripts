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

# Detect the operating system
if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Error: Unable to detect the operating system."
    exit 1
fi

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
colorred="\033[31m"
colorpowder_blue="\033[1;36m" #with bold
colorblue="\033[34m"
colornormal="\033[0m"
colorwhite="\033[97m"
colorlightgrey="\033[90m"
echo
printf "               ${colorred} ##       ${colorpowder_blue} .\n"
printf "         ${colornormal}${colorred} ## ## ##      ${colorpowder_blue} ==       ${colorpowder_blue} _____   ____   _____ _  ________ _____  \n"
printf "       ${colornormal}${colorred}## ## ## ##      ${colorpowder_blue}===       ${colorpowder_blue}|  __ \ / __ \ / ____| |/ /  ____|  __ \ \n"
printf "   /\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\\\___/ ===     ${colorpowder_blue}| |  | | |  | | |    | ' /| |__  | |__) |\n"
printf "  ${colorpowder_blue}{${colorblue}                      ${colorpowder_blue}/  ===-  ${colorpowder_blue}| |  | | |  | | |    |  < |  __| |  _  / \n"
printf "   \\\______${colorwhite} o ${colorpowder_blue}         __/         | |__| | |__| | |____| . \| |____| | \ \ \n"
printf "     \\\    \\\        __/            ${colorpowder_blue}|_____/ \____/ \_____|_|\_\______|_|  \_\ \n"
printf "      \\\____\\\______/ \n${colornormal}"
printf "                                                        ${colorred}Created by: sd-itlab\n"
printf "${colornormal}============================================================================="
echo
}

displayupdate() {
cat <<EOF
=============================================================================
     _____            __                    __  __          __      __     
    / ___/__  _______/ /____  ____ ___     / / / /___  ____/ /___ _/ /____ 
    \__ \/ / / / ___/ __/ _ \/ __  __ \   / / / / __ \/ __  / __  / __/ _ \ 
   ___/ / /_/ (__  ) /_/  __/ / / / / /  / /_/ / /_/ / /_/ / /_/ / /_/  __/
  /____/\__  /____/\__/\___/_/ /_/ /_/   \____/  ___/\____/\____/\__/\___/ 
       /____/                                /_/                  
                            Created by: sd-itlab
=============================================================================
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
    color_echo 32 "   System has been updated and is now up-to-date."
    echo
}



################################################################################################################
###############                              Docker - installation                               ###############
################################################################################################################
docker_setup() {
    clear
    displaydocker
    echo

    # Install dependencies
    run_command apt-get install -y ca-certificates curl

    # Create directory for keyrings
    run_command install -m 0755 -d /etc/apt/keyrings

    # Download Docker's GPG key
    run_command curl -fsSL https://download.docker.com/linux/$OS/gpg -o /etc/apt/keyrings/docker.asc

    # Adjust permissions for the GPG key
    run_command chmod a+r /etc/apt/keyrings/docker.asc

    # Add Docker repository to Apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$OS \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  run_command tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update Apt repositories
    run_command apt-get update

    # Install Docker packages
    run_command apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl stop docker

    # Check if /etc/docker directory exists
    if [ ! -d "/etc/docker" ]; then
        mkdir /etc/docker
    fi

    # Check if /etc/docker/daemon.json exists
    if [ ! -e "/etc/docker/daemon.json" ]; then
    # Change docker directory for more space
cat <<EOL > /etc/docker/daemon.json
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

    systemctl start docker
    clear
    displaydocker
    echo
    color_echo 32 "   Installation of Docker and Docker-Compose completed."
    color_echo 32 "   Information: Default-Directory was changed to [/home/docker],"
    color_echo 32 "                for more storage capacity."
    echo
}



################################################################################################################
###############                            Dockerapps - installation                             ###############
################################################################################################################
app_menu() {
    # Function for installing apps
    while true; do

        clear
        displaydocker
        # Show menu options
        echo
        echo -e "\e[1;33m   [\033[1;36m1\e[1;33m] Portainer\e[0m              [Dashboard for docker containers]"     
        echo -e "\e[1;33m   [\033[1;36m2\e[1;33m] Adguard Home\e[0m           [Network-wide ad & tracker blocker]"
        echo -e "\e[1;33m   [\033[1;36m3\e[1;33m] Uptime Kuma\e[0m            [Uptime-monitoring]"
        echo -e "\e[1;33m   [\033[1;36m4\e[1;33m] Watchtower\e[0m             [Automatic updating of docker containers]"
        echo -e "\e[1;33m   [\033[1;36m5\e[1;33m] Grafana_Stack\e[0m          [Data visualization]"
        echo -e "\e[1;33m   [\033[1;36m6\e[1;33m] Nginx-Proxy-Manager\e[0m    [Reverse proxy with LetsEncrypt]"
        echo -e "\e[1;33m   [\033[1;36m7\e[1;33m] Heimdall\e[0m               [Dashboards for Favorites]"
        echo
        echo "============================================================================="
        echo

        # Query user input
        read -p "   Please select an option (1-8) or Quit (Q): " user_choice

        # Process menu options
        case $user_choice in
            1) install_portainer ;;
            2) install_adguard_home ;;
            3) install_uptime_kuma ;;
            4) install_watchtower ;;
            5) install_grafana_stack ;;
            6) install_npm ;;
            7) install_heimdall ;;
            Q|q) return ;;
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
    echo -e "   Portainer can now be reached at the following address >"
    echo -e "   \e[32mhttp://$(get_ip_address):9000\e[0m"
    echo
    read -p "   Press Enter to return to the menu."
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
    echo -e "   Adguard can now be reached at the following address > "
    echo -e "   For first setup use: \e[32mhttp://$(get_ip_address):33000\e[0m"
    echo -e "   After setup use: \e[32mhttp://$(get_ip_address):30080\e[0m"
    echo
    read -p "   Press Enter to return to the menu."        
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
    echo -e "   Uptime Kuma can now be reached at the following address >"
    echo -e "   \e[32mhttp://$(get_ip_address):3001\e[0m"
    echo
    read -p "   Press Enter to return to the menu."    
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
    read -p "   Press Enter to return to the menu."    
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
    scrape_interval: 10s
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'Localhost'
    scrape_interval: 10s
    static_configs:
      - targets: ['node_exporter:9100']
EOL


	run_command docker network create grafana_network
	
	run_command docker volume create prometheus_data
    run_command docker run -d --hostname=prometheus --name=g_prometheus --network=grafana_network --restart=unless-stopped \
        -p 9090:9090 \
        -v /etc/prometheus:/etc/prometheus \
        -v prometheus_data:/prometheus \
        prom/prometheus:latest

	run_command docker volume create grafana_data
    run_command docker run -d --hostname=grafana --name=g_grafana --network=grafana_network --restart=unless-stopped \
        -p 3000:3000 \
        -v grafana_data:/var/lib/grafana \
        grafana/grafana:latest
		
    run_command docker run -d --hostname=node_exporter --name=g_node_exporter --network=grafana_network --restart=unless-stopped \
		--pid=host \
        -v /:/host:ro,rslave \
        quay.io/prometheus/node-exporter:v1.5.0 --path.rootfs=/host

    clear
    displaydocker
    echo
    print_colored_section_header "Install Grafana-Fritzbox..."
    echo 
    read -p "Would you like to install the fritzbox-prometheus-exporter as well? (Y/N): " install_fritzbox_exporter

    if [ "$install_fritzbox_exporter" == "y" ]; then
        read -p "Enter the IP address of your Fritzbox: " fb_exporter_gateway_url
        read -p "Enter the fritzbox user name (USERNAME) for fritzbox-prometheus-exporter: " fb_exporter_username
        read -p "Enter the fritzbox password (PASSWORD) for fritzbox-prometheus-exporter: " fb_exporter_passwort
        echo
        run_command docker run -d --hostname=fritzbox_exporter --name=g_fritzbox_exporter --network=grafana_network --restart=unless-stopped \
            -p 9042:9042 \
            -e USERNAME=$fb_exporter_username \
            -e PASSWORD=$fb_exporter_password \
            -e GATEWAY_URL=http://$fb_exporter_gateway_url:49000 \
            -e LISTEN_ADDRESS=0.0.0.0:9042 \
            mineyannik/fritzbox_exporter:latest

            fritzbox_exporter_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' fritzbox_exporter)

cat <<EOL >> /etc/prometheus/prometheus.yml

  - job_name: 'fritzbox_exporter'
    static_configs:
      - targets: ['g_fritzbox_exporter:9042']
EOL
        run_command docker restart prometheus
    else
        color_echo 31 "fritzbox-prometheus-exporter will be not installed"
    fi

    clear
    displaydocker
    echo
    echo -e "   Grafana can now be reached at the following address >"
    echo -e "   \e[32mhttp://$(get_ip_address):3000\e[0m"
    echo
    echo -e "   Node-Exporter can now be reached at the following address >" 
    echo -e "   \e[32mhttp://$(get_ip_address):9090\e[0m"
    echo
    read -p "   Press Enter to return to the menu."
}

install_npm() {

    clear
    displaydocker
    echo
    print_colored_section_header "Install Nginx-Proxy-Manager"
    run_command docker network create npm_network
    run_command docker volume create npm_data
    run_command docker run -d --hostname=npm --name=nginx-proxy-manager --network=npm_network --restart=always \
        -v /npm_data/data:/data \
        -v /npm_data/letsencrypt:/etc/letsencrypt \
        -p 80:80 \
        -p 443:443 \
        -p 81:81 \
        -e TZ=Europe/Berlin \
        jc21/nginx-proxy-manager:latest
        clear
    displaydocker
    echo
    echo -e "   Nginx Proxy Manager can now be reached at the following address >"
    echo -e "   \e[32mhttp://$(get_ip_address):81\e[0m"
    echo
    echo -e "   Default email: \e[32madmin@example.com \033[0m| Default password: \e[32mchangeme\e[0m"
    echo
    read -p "   Press Enter to return to the menu."    
}

install_heimdall() {

    clear
    displaydocker
    echo
    print_colored_section_header "Install Heimdall"
    run_command docker volume create heimdall_data
    run_command docker run -d --hostname=heimdall --name=heimdall --restart=always \
        -v /heimdall_data/config:/app/config \
        -p 8080:80 \
        linuxserver/heimdall:latest
        clear
    displaydocker
    echo
    echo -e "   Heimdall can now be reached at the following address >"
    echo -e "   \e[32mhttp://$(get_ip_address):8080\e[0m"
    echo
    read -p "   Press Enter to return to the menu."    
}

################################################################################################################
###############                                    Mainmenu                                      ###############
################################################################################################################
while true; do
    clear
    displaydocker
    # Process menu options
    echo
    echo -e "\e[1;33m   [\033[1;36m1\e[1;33m] Perform system update\e[0m     [Update the system]"
    echo
    echo -e "\e[1;33m   [\033[1;36m2\e[1;33m] Install Docker\e[0m            [Install Docker and Docker-Compose]"
    echo
    echo -e "\e[1;33m   [\033[1;36m3\e[1;33m] Install Applications\e[0m      [Install Docker-Apps]"
    echo
    echo
    echo
    echo "============================================================================="
    echo
    # Query user input
    read -p "   Please select an option (1-3) or Quit (Q): " choice

    # Process menu options
    case $choice in
        1) sys_update ; read -p "   Press Enter to return to the main menu." ;;
        2) docker_setup ; read -p "   Press Enter to return to the main menu." ;;
        3) app_menu ;;
        Q|q)
            clear
            exit
            ;;
        *) ;;
    esac
done
