#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run as root (use sudo)" 
   exit 1
fi

# ---- 🔹 Update and Upgrade System ----
echo "Updating and upgrading system..."
apt update -y && apt upgrade -y

# ---- 🔹 Essential System Configurations ----
echo "Setting up security configurations..."

# Enable Firewall
apt install -y ufw
ufw enable
ufw allow OpenSSH
ufw status verbose

# Secure SSH (Disable root login)
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart ssh

# Create a Normal User (Recommended for daily use)
read -p "Enter username for normal user: " user
read -sp "Enter password for ${user}: " password
echo
useradd -m -s /bin/bash "$user"
echo "$user:$password" | chpasswd
usermod -aG sudo "$user"

# ---- 🔹 System Utilities ----
echo "Installing essential system utilities..."
apt install -y curl wget git vim neofetch htop tmux unzip zsh

# Automate Oh-My-Zsh installation (skip user interaction)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set Zsh as default shell
chsh -s $(which zsh)

# Add Useful Aliases
echo 'alias ll="ls -lah"' >> ~/.zshrc
echo 'alias grep="grep --color=auto"' >> ~/.zshrc
echo 'alias ..="cd .."' >> ~/.zshrc
echo 'alias cc="clear"' >> ~/.zshrc
source ~/.zshrc

# ---- 🔹 Install CTF Tools ----
echo "Installing CTF Tools..."

# Web Exploitation
apt install -y burpsuite sqlmap gobuster wfuzz whatweb dirb

# Cryptography & Steganography
apt install -y john binwalk exiftool steghide outguess
pip install stegcracker ciphey

# Reverse Engineering
apt install -y gdb radare2 checksec qemu qemu-user-static
git clone https://github.com/pwndbg/pwndbg.git && cd pwndbg && ./setup.sh
pip install lief angr

# Privilege Escalation & Post-Exploitation
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -O /usr/local/bin/linpeas.sh && chmod +x /usr/local/bin/linpeas.sh
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat -O /usr/local/bin/winPEAS.bat
wget https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64 -O /usr/local/bin/pspy64 && chmod +x /usr/local/bin/pspy64
apt install -y chisel

# General Utilities
apt install -y binutils file xxd netcat wireshark seclists impacket-scripts

# Binary Exploitation
apt install -y gdb
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit
wget -O ~/.gdbinit-gef.py https://gef.blah.cat/py
echo "source ~/.gdbinit-gef.py" >> ~/.gdbinit
apt install -y ropgadget
pip install pwntools one_gadget

# Network & Forensics
apt install -y tcpdump tshark bettercap responder
wget https://github.com/netresec/NetworkMiner/releases/latest/download/NetworkMiner.zip -O /opt/NetworkMiner.zip

# Reconnaissance & Enumeration
apt install -y nmap amass sublist3r

# Automation & Exploitation
apt install -y metasploit-framework
pip install git+https://github.com/Tib3rius/AutoRecon.git

# SecLists
apt install -y seclists

# ---- 🔹 Install Developer & Productivity Tools ----
echo "Installing Productivity Tools..."

# Install Sublime Text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | tee /usr/share/keyrings/sublimehq-archive.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive.gpg] https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
apt update && apt install -y sublime-text

# Install Python & Pip Essentials
apt install -y python3-pip python3-venv
pip install --upgrade pip setuptools wheel

# Install Docker & Set Up Non-Root Access
apt install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker "$user"

# ---- 🔹 Privacy & Security Enhancements ----
echo "Enhancing security and privacy..."

# Install and Configure Anonsurf (Tor for Anonymous Browsing)
apt install -y tor proxychains
git clone https://github.com/Und3rf10w/kali-anonsurf.git
cd kali-anonsurf
./installer.sh
cd ..

# ---- 🔹 Python Package Fix and Setup ----
echo "Fixing Python package installation issue..."

# Ensure Python packages are installed in user-space
pip install --user --upgrade pip setuptools wheel

# If the environment is externally managed, use a virtual environment to isolate package installations
if ! command -v virtualenv &> /dev/null; then
    echo "virtualenv not found. Installing virtualenv..."
    apt install -y python3-virtualenv
fi

# Create a virtual environment (if you want to install Python packages inside the virtualenv)
echo "Creating virtual environment for Python packages..."
mkdir -p ~/python_env
cd ~/python_env
virtualenv venv
source venv/bin/activate

# Install Python packages inside virtual environment
echo "Installing Python packages inside virtual environment..."
pip install pwntools

# Deactivate the virtual environment when done
deactivate

# ---- 🔹 System Cleanup ----
echo "Cleaning up unnecessary packages..."
apt remove -y libreoffice* hexchat pidgin thunderbird transmission
apt autoremove -y

# ---- 🔹 Final Touches ----
echo "Setup complete! Restart your system for all changes to take effect."
