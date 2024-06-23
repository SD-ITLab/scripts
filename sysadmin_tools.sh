#!/bin/bash
# Function for executing commands with optional sudo
run_command() {
    if [ -x "$(command -v sudo)" ]; then
        sudo "$@"
    else
        "$@"
    fi
}

# Function for colorcodes
color_echo() {
    local color_code=$1
    shift
    echo -e "\e[1;${color_code}m$@\e[0m"
}

displaymenu() {
cat <<EOF
==========================================================================
       _____                              _____      __
      / ___/___  _______  __________     / ___/___  / /___  ______
      \__ \/ _ \/ ___/ / / / ___/ _ \    \__ \/ _ \/ __/ / / / __ \ 
     ___/ /  __/ /__/ /_/ / /  /  __/   ___/ /  __/ /_/ /_/ / /_/ /
    /____/\___/\___/\__,_/_/   \___/   /____/\___/\__/\__,_/ .___/
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

displayssh() {
cat <<EOF
==========================================================================        
        _____                              _____ __         ____
       / ___/___  _______  __________     / ___// /_  ___  / / /
       \__ \/ _ \/ ___/ / / / ___/ _ \    \__ \/ __ \/ _ \/ / /
      ___/ /  __/ /__/ /_/ / /  /  __/   ___/ / / / /  __/ / /
     /____/\___/\___/\__,_/_/   \___/   /____/_/ /_/\___/_/_/
                           Created by: sd-itlab
==========================================================================
EOF
}

displayuser() {
cat <<EOF
==========================================================================
           __  __                  _____      __                      
          / / / /_______  _____   / ___/___  / /___  ______           
         / / / / ___/ _ \/ ___/   \__ \/ _ \/ __/ / / / __ \ 
        / /_/ (__  )  __/ /      ___/ /  __/ /_/ /_/ / /_/ /
        \____/____/\___/_/      /____/\___/\__/\__,_/ .___/
                                                   /_/
                           Created by: sd-itlab
==========================================================================
EOF
}

displaycrowdsec() {
cat <<EOF
==========================================================================
               ______                       __
              / ____/________ _      ______/ /_______  _____
             / /   / ___/ __ \ | /| / / __  / ___/ _ \/ ___/
            / /___/ /  / /_/ / |/ |/ / /_/ (__  )  __/ /__
            \____/_/   \____/|__/|__/\__,_/____/\___/\___/
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
###############                                 USER & SSH - KEY                                 ###############
################################################################################################################
user_key_menu() {

    user_exists() {
        id "$1" &>/dev/null
    }

    list_normal_users() {
        clear
        displayuser
        echo
        echo -e "\e[1;33mavailable users\e[0m"
        echo -e "\e[1;33m-------------------\e[0m"
        getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}'
        echo -e "\e[1;33m-------------------\e[0m"
        echo
    }

    # Function for deleting a user
    delete_user_menu() {
        list_normal_users
        echo
        read -p "Would you like to delete a user? (Y/N): " delete_choice
        case $delete_choice in
            [YyJj])
                read -p "Enter the user name you wish to delete: " username
                if [ -n "$username" ]; then
                    read -p "Are you sure you want to delete the user '$username' and its home folder? (Y/N): " confirm
                    case $confirm in
                        [YyJj])
                            userdel -r "$username"
                            rm -rf /home/$username
                            clear
                            displayuser
                            echo
                            color_echo 32 "User '$username' was successfully deleted."
                            color_echo 32 "The Homefolder of '$username' was successfully deleted"
                            echo
                            read -p "Press Enter to return to the menu."
                            ;;
                        *) 
                            echo
                            color_echo 31 "Deletion of the user canceled."
                            echo
                            read -p "Press Enter to return to the menu." 
                            ;;
                    esac
                else
                    echo
                    color_echo 31 "Invalid user name"
                    echo
                    read -p "Press Enter to return to the menu." 
                fi
                ;;
            *) 
                echo
                color_echo 31 "Deletion of the user canceled."
                echo
                read -p "Press Enter to return to the menu."  
                ;;
        esac
    }

    # Function for creating a new user with SSH and Sudo rights
    create_user_menu() {
        clear
        displayuser
        echo
        read -p "   Would you like to create a new user? (Y/N): " create_choice
        case $create_choice in
            [YyJj])
                read -p "   Enter the user name: " username
                if [ -n "$username" ]; then
                    ssh_group=""
                    sudo_group=""

                    # Check if 'ssh' group exists, otherwise check for '_ssh'
                    if getent group ssh > /dev/null; then
                        ssh_group="ssh"
                    elif getent group _ssh > /dev/null; then
                        ssh_group="_ssh"
                    fi

                    # Check if 'sudo' group exists
                    if getent group sudo > /dev/null; then
                        sudo_group="sudo"
                    fi

                    read -p "   Should the user have SSH rights? (Y/N): " ssh_choice
                    case $ssh_choice in
                        [YyJj])
                            ssh_group="ssh"
                            ;;
                    esac

                    read -p "   Should the user have Sudo rights? (Y/N): " sudo_choice
                    case $sudo_choice in
                        [YyJj])
                            sudo_group="sudo"
                            ;;
                    esac

                    adduser --shell /bin/bash "$username"

                    # Add the user to the groups
                    if [ -n "$ssh_group" ]; then
                        usermod -aG "$ssh_group" "$username"
                    fi

                    if [ -n "$sudo_group" ]; then
                        usermod -aG "$sudo_group" "$username"
                    fi

                    clear
                    displayuser
                    echo

                    if [ -n "$ssh_group" ] && [ -n "$sudo_group" ]; then
                        color_echo 32 "User '$username' was successfully created with Sudo and SSH rights."
                        echo
                        read -p "Press Enter to return to the menu." 
                    elif [ -n "$ssh_group" ]; then
                        color_echo 32 "User '$username' was successfully created with SSH rights."
                        echo
                        read -p "Press Enter to return to the menu." 
                    elif [ -n "$sudo_group" ]; then
                        color_echo 32 "User '$username' was successfully created with Sudo rights."
                        echo
                        read -p "Press Enter to return to the menu."     
                    else
                        color_echo 32 "User '$username' was successfully created"
                        echo
                        read -p "Press Enter to return to the menu." 
                    fi
                else
                    color_echo 31 "Invalid username."
                    echo
                    read -p "Press Enter to return to the menu." 
                fi
                ;;
            *) 
                color_echo 31 "Creation of the user canceled." 
                echo
                read -p "Press Enter to return to the menu." 
                ;;
        esac
    }

    # Function for editing a user
    edit_user_menu() { 
        list_normal_users
        echo
        read -p "For which user would you like to edit the rights? " username

        if user_exists "$username"; then
            echo
            echo -e "\e[1;33mRights for user '$username':\e[0m"
            echo -e "\e[1;33m-----------------------------------\e[0m"

            ssh_group=""
            sudo_group=""

            # Check if 'ssh' group exists, otherwise check for '_ssh'
            if getent group ssh > /dev/null; then
                ssh_group="ssh"
            elif getent group _ssh > /dev/null; then
                ssh_group="_ssh"
            fi

            # Check if 'sudo' group exists
            if getent group sudo > /dev/null; then
                sudo_group="sudo"
            fi

            if groups "$username" | grep -q "$ssh_group"; then
                echo "SSH rights: Assigned"
            else
                echo "SSH rights: Not assigned"
            fi

            if groups "$username" | grep -q "$sudo_group"; then
                echo "Sudo rights: Assigned"
            else
                echo "Sudo rights: Not assigned"
            fi

            echo
            read -p "Would you like to edit rights? (Y/N): " edit_choice
            case $edit_choice in
                [YyJj])
                    echo
                    read -p "Which rights would you like to modify? (SSH/Sudo): " modify_rights
                    case $modify_rights in
                        [Ss][Ss][Hh])
                            read -p "Would you like to add or remove SSH rights? (Add/Del): " ssh_edit_choice
                            case $ssh_edit_choice in
                                [Aa][Dd][Dd])
                                    usermod -aG "$ssh_group" "$username"
                                    clear
                                    echo
                                    color_echo 32 "SSH rights for user '$username' have been successfully added."
                                    echo
                                    read -p "Press Enter to return to the menu."
                                    ;;
                                [Dd][Ee][Ll])
                                    deluser  "$username" "$ssh_group"
                                    clear
                                    echo
                                    color_echo 32 "SSH rights for user '$username' have been successfully removed."
                                    echo
                                    read -p "Press Enter to return to the menu."
                                    ;;
                                *) echo "Invalid input." ;;
                            esac
                            ;;
                        [Ss][Uu][Dd][Oo])
                            read -p "Would you like to add or remove Sudo rights? (Add/Del): " sudo_edit_choice
                            case $sudo_edit_choice in
                                [Aa][Dd][Dd])
                                    usermod -aG "$sudo_group" "$username"
                                    clear
                                    echo
                                    color_echo 32 "Sudo rights for user '$username' have been successfully added."
                                    echo
                                    read -p "Press Enter to return to the menu."
                                    ;;
                                [Dd][Ee][Ll])
                                    deluser "$username" "$sudo_group"
                                    clear
                                    echo
                                    color_echo 32 "Sudo rights for user '$username' have been successfully removed."
                                    echo
                                    read -p "Press Enter to return to the menu."
                                    ;;
                                *) echo "Invalid input." ;;
                            esac
                            ;;
                        *) echo "Invalid input." ;;
                    esac
                    ;;
                *) echo "Rights remain unchanged." ;;
            esac
        else
            color_echo 31 "User '$username' does not exist."
        fi
    }

    # Function for creating an SSH key for a user
    create_ssh_key() {
        list_normal_users
        echo
        read -p "For which user do you want to create an SSH key? " ssh_user

        if [ "$ssh_user" == "root" ]; then
            ssh_dir="/root/.ssh"
        else
            ssh_dir="/home/$ssh_user/.ssh"
        fi

        if user_exists "$ssh_user"; then
        run_command mkdir -p "$ssh_dir"
        run_command ssh-keygen -t rsa -b 4096 -f "$ssh_dir/id_rsa"
        run_command mv "$ssh_dir/id_rsa.pub" "$ssh_dir/authorized_keys"
            clear
            displayuser
            echo 
            echo "                      Private key of > "$ssh_user" <"
            echo "=========================================================================="
            echo
            run_command cat "$ssh_dir/id_rsa"
            echo
            echo
            read -p "Press Enter to return to the menu."
        else
            clear
            displayuser
            echo
            color_echo 31 "User '$ssh_user' does not exist."
            echo
            read -p "Press Enter to return to the menu."
        fi
    }

    # Function for managing users
    while true; do

        clear
        displayuser
        # Show menu options
        echo
        echo -e "\e[1;33m   [1] Show all users\e[0m     [Listing all users]"
        echo     
        echo -e "\e[1;33m   [2] Delete User\e[0m        [Remove user and there home folder]"
        echo
        echo -e "\e[1;33m   [3] Create new user\e[0m    [Create a new user with permissions]"
        echo
        echo -e "\e[1;33m   [4] Edit user rights\e[0m   [Add or remove SSH and Sudo permissions]"
        echo
        echo -e "\e[1;33m   [5] Create SSH-KEY\e[0m     [Create a SSH-Key for user]"
        echo
        echo
        echo -e "\e[1;33m   [6] Return to the main menu\e[0m"
        echo
        echo "=========================================================================="
        echo

        # Query user input
        read -p "   Please select an option (1-6): " user_choice

        # Process menu options
        case $user_choice in
            1) list_normal_users ; read -p "Press Enter to return to the main menu." ;;
            2) delete_user_menu  ;;
            3) create_user_menu  ;;
            4) edit_user_menu ;;
            5) create_ssh_key ;;
            6) return ;;
            *) echo "Invalid option. Please select again." ;;
        esac
    done
}


################################################################################################################
###############                               SSH - Configuration                                ###############
################################################################################################################
ssh_menu() {
    clear
    displayssh

    # File path to the sshd_config file
    sshd_config="/etc/ssh/sshd_config"

    # Function for updating the SSH configuration
    update_ssh_config() {
        local pattern=$1
        local value=$2
        # Create a backup copy
        cp "$sshd_config" "$sshd_config.bak"
        # Remove comment characters # in front of the lines (if present)
        sed -i "/^$pattern/ s/^#*/#/" "$sshd_config"
        # Set the new value
        sed -i "s/^#*$pattern.*/$pattern $value/" "$sshd_config"
    }

    # User queries for SSH configuration
    echo
    echo -e "\e[1;33mEnter the new SSH port (default: 22) (number between 30000 and 65535):\e[0m "
    read new_port
    echo
    echo -e "\e[1;33mShould root login via SSH be allowed? (yes/no):\e[0m "
    read new_permit_root_login
    echo
    echo -e "\e[1;33mShould Public Key Authentication be activated? (yes/no):\e[0m "
    read new_pubkey_authentication
    echo
    echo -e "\e[1;33mShould Password Authentication be activated? (yes/no):\e[0m "
    read new_password_authentication
    echo

    # Update SSH-configuration
    update_ssh_config "Port" "$new_port"
    update_ssh_config "PermitRootLogin" "$new_permit_root_login"
    update_ssh_config "PubkeyAuthentication" "$new_pubkey_authentication"
    update_ssh_config "PasswordAuthentication" "$new_password_authentication"

    # Restart SSH-Dienst service
    run_command ufw allow $new_port
    run_command service ssh restart

    # Colored output
    clear
    displayssh
    echo
    color_echo 32 "   SSH has been successfully configured"
    echo
    color_echo 32 "   Your new SSH Port is now: '$new_port'"
    color_echo 32 "   The Settings for PermitRootLogin was set to: '$new_permit_root_login'"
    color_echo 32 "   The Settings for PubkeyAuthentication was set to: '$new_pubkey_authentication'"
    color_echo 32 "   The Settings for PasswordAuthentication was set to: '$new_password_authentication'"
    echo
}



################################################################################################################
###############                              Crowdsec - Installation                             ###############
################################################################################################################
crowdsec_menu() {
    clear
    displaycrowdsec

    # Function for updating the Crowdsec configuration
    update_crowdsec_config() {
        local section=$1
        local pattern=$2
        local value=$3
        # Check whether the line already exists
        if ! grep -q "$pattern" $crowdsec_config; then
            # Add the line if not available
            sed -i "/$section/ a\\$pattern $value" $crowdsec_config
        else
            # Remove comment characters # in front of the lines (if present)
            sed -i "/^$pattern/ s/^#*/#/" $crowdsec_config
            # Set the new value
            sed -i "s/^#*$pattern.*/$pattern $value/" $crowdsec_config
        fi
    }

    # Function for updating the listen_uri in the Crowdsec configuration
    update_listen_uri() {
        local value=$1
        local config_file=$2
        # Check whether the line already exists
        if grep -q "^\s*listen_uri:" "$config_file"; then
            # Set the new value
            sed -i "s/^\(\s*listen_uri:\s*\).*/\1$value/" "$config_file"
            echo "listen_uri was successfully updated to $value."
        else
            echo "Error: listen_uri not found in $config_file."
        fi
    }

    # Function for updating the crowdsec-firewall-bouncer-iptables configuration
    update_firewall_bouncer_config() {
        local pattern=$1
        local value=$2
        # Check whether the line already exists
        if grep -q "$pattern" "$firewall_bouncer_config"; then
            # Set the new value
            sed -i "s|^\($pattern\s*\).*|\1$value|" "$firewall_bouncer_config"
        else
            # Add the line if not available
            echo "$pattern $value" >> "$firewall_bouncer_config"
        fi
    }

    # Function for updating the local_api_credentials.yaml
    update_local_api_credentials() {
        local local_api_credentials="/etc/crowdsec/local_api_credentials.yaml"
        if [ -f "$local_api_credentials" ]; then
            sed -i "s#url:.*#url: http://127.0.0.1:8081#" "$local_api_credentials"
            echo "local_api_credentials.yaml has been successfully updated."
        else
            echo "Error: $local_api_credentials not found."
        fi
    }

    # Installation of Crowdsec-dependencies
    run_command apt-get install iptables iptables-persistent -y
    run_command apt-get install ufw -y
    run_command ufw --force enable
    # Automatically detect SSH port from sshd_config
    ssh_port=$(grep -oP "(?<=^Port\s)(\d+)" /etc/ssh/sshd_config)
    # Use default port 22 if not found in the configuration file
    ssh_port=${ssh_port:-22}
    # Set the new SSH port
    new_port2=$ssh_port
    # Allow incoming connections on the new SSH port
    run_command ufw allow $new_port2
    run_command ufw allow 8081
    # Check if the host is a Proxmox host
    if dpkg -l | grep -q pve-manager; then
        run_command ufw allow 8006
    fi
    run_command apt-get install curl -y
    run_command curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash
    run_command apt-get install crowdsec -y

    # Crowdsec-configuration
    crowdsec_config="/etc/crowdsec/config.yaml"

    # Section heading
    echo
    color_echo 34 "Update CrowdSec configuration..."

    # add db_config: use_wal: true
    update_crowdsec_config "db_config:" "  use_wal:" "true" "$crowdsec_config"

    # Change api: server: listen_uri to 127.0.0.1:8081
    update_listen_uri "127.0.0.1:8081" "$crowdsec_config"

    # function for updating the local_api_credentials.yaml
    update_local_api_credentials
    
    # Colored output
    run_command systemctl restart crowdsec
    color_echo 32 "CrowdSec configuration has been successfully updated."
    echo



    # Crowdsec-Bouncer-installation
    run_command apt-get install crowdsec-firewall-bouncer-iptables -y

    # Crowdsec-Firewall-Bouncer-Iptables-configuration
    firewall_bouncer_config="/etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml"

    echo
    color_echo 34 "Update CrowdSec firewall bouncer configuration"
    echo

    # change api_url to http://127.0.0.1:8081/
    update_firewall_bouncer_config "api_url:" "http://127.0.0.1:8081/" "$firewall_bouncer_config"
    color_echo 32 "CrowdSec Firewall-Bouncer-Iptables configuration has been successfully updated."
    echo

    # Restart UFW and Crowdsec-service
    run_command systemctl restart ufw
    run_command systemctl restart crowdsec

    # Information output
    clear
    displaycrowdsec
    echo
    color_echo 32 "   IPtables, UFW and Crowdsec are now installed"
    echo
    color_echo 32 "   UFW has opened port for SSH and port 8081 (Crowdsec)"
    color_echo 32 "   CrowdSec configuration has been successfully updated."
    color_echo 32 "   CrowdSec Firewall-Bouncer-Iptables configuration has been successfully updated."
    echo
}



################################################################################################################
###############                                    Mainmenu                                      ###############
################################################################################################################
while true; do
    clear
    displaymenu
    # Process menu options
    echo
    echo -e "\e[1;33m   [1] Updating the system\e[0m     [Perform system update]"
    echo
    echo -e "\e[1;33m   [2] User - Management\e[0m       [Manage users and authorizations]"
    echo
    echo -e "\e[1;33m   [3] SSH - Configuration\e[0m     [Configure SSH settings]"
    echo
    echo -e "\e[1;33m   [4] CrowdSec Installation\e[0m   [Installing and configuring CrowdSec]" 
    echo
    echo
    echo -e "\e[1;33m   [5] Quit\e[0m"
    echo
    echo "=========================================================================="
    echo
    # Query user input
    read -p "   Please select an option (1-5): " choice

    # Process menu options
    case $choice in
        1) sys_update ; read -p "Press Enter to return to the main menu." ;;
        2) user_key_menu ;;
        3) ssh_menu ; read -p "Press Enter to return to the main menu." ;;
        4) crowdsec_menu ; read -p "Press Enter to return to the main menu." ;;
        5)
            clear
            exit
            ;;
        *) ;;
    esac
done
