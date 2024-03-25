#!/bin/bash

# Goal: Script which automatically sets up a new Ubuntu Machine after installation
# This is a basic install, easily configurable to your needs

# Test to see if user is running with root privileges.
if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with or root' >&2
 exit 1
fi

# Ensure system is up to date
apt-get update -y 

# Upgrade the system
apt-get upgrade -y

# Install OpenSSH
apt-get install openssh-server -y
apt-get install wget -y

# Disabling root login 
echo "PermitRootLogin no" >> /etc/ssh/sshd_config 
echo "PermitEmptyPasswords no" /etc/ssh/sshd_config

# Рестартиране на SSH
systemctl restart ssh


# Message of the day 
wget https://raw.githubusercontent.com/jwandrews99/Linux-Automation/master/misc/motd.sh
mv motd.sh /etc/update-motd.d/05-info
chmod +x /etc/update-motd.d/05-info

# Automatic downloads of security updates
apt-get install -y unattended-upgrades
echo "Unattended-Upgrade::Allowed-Origins {
#   "${distro_id}:${distro_codename}-security";
#//  "${distro_id}:${distro_codename}-updates";
#//  "${distro_id}:${distro_codename}-proposed";
#//  "${distro_id}:${distro_codename}-backports";

#Unattended-Upgrade::Automatic-Reboot "true"; 
#}; " >> /etc/apt/apt.conf.d/50unattended-upgrades


# Docker option install 
echo "
######################################################################################################

Do you want to install docker? If so type y / If you dont want to install enter n

######################################################################################################
"
read docker

if [[ "$docker" == "y" ]] || [[ "$docker" == "yes" ]]; then
    apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
    apt-get update -y
    apt-cache policy docker-ce
    apt install docker-ce -y
    apt-get install docker-compose -y 

    echo " 
    
        Installing Portainer on port 9000

    "

    docker volume create portainer_data
    docker run -d -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

    echo "
elif [[ "$docker" == "n" ]] || [[ "$docker" == "no" ]]; then
    echo "Skipping Docker installation."
else
    echo "Invalid input. Please enter 'y' or 'n'."
fi

#####################################################################################################    
                            Congrats Docker has been installed
######################################################################################################
"
    docker -v

else 
    echo "Docker was not installed"
 
fi

# Wireguard install
echo "
######################################################################################################

Would you like to install a wireguard VPN Server? If so enter y / If you dont want to install enter n

######################################################################################################
"
read $vpn

if [[ $vpn -eq "y" ]] || [ $vpn -eq "yes" ]] ; then 
    wget https://raw.githubusercontent.com/l-n-s/wireguard-install/master/wireguard-install.sh -O wireguard-install.sh
    bash wireguard-install.sh

elif  [[ $vpn -eq "n" ]] || [ $vpn -eq "no" ]] ; then 
    echo "Wireguard wasnt installed"
else 
    echo "Error Install Aborted!"
    exit 1
fi

# Cleanup
apt autoremove
apt clean 

echo "
######################################################################################################

                                        A few tid bits

In order to use SpeedTest - Just use "speedtest" in the cli

Reboot your server to fully configure the vpn service

When using the VPN service on a device simply use the config file in you home directory. 
To create a new config enter  bash wireguard-install.sh in the cli and choose a new name

If you installed Docker a portainer management image is running on ip:9000

######################################################################################################
"

exit 0
