#!/bin/bash

set -e

# Define colors for output
BOLD_GREEN='\033[1;32m'
BOLD_RED='\033[1;31m'
BOLD_YELLOW='\033[1;33m'
BOLD_CYAN='\033[1;36m'
BOLD_PURPLE='\033[1;35m'
NC='\033[0m' # No Color

###### Check for sudo ######
if ! sudo -v; then
  echo -e "${BOLD_RED}[✗] This script must be run with sudo privileges. Please run 'sudo $0'${NC}"
  exit 1
fi

###### Handle existing Puppet installation ######
echo -e "${BOLD_CYAN}[*] Checking for existing Puppet installation...${NC}"

# Check for puppet-related packages
PUPPET_PACKAGES=$(dpkg -l | grep -i puppet || true)
FOUND_PACKAGES=false
if [ ! -z "$PUPPET_PACKAGES" ]; then
    FOUND_PACKAGES=true
    echo -e "${BOLD_YELLOW}[!] Found existing Puppet packages:${NC}"
    echo "$PUPPET_PACKAGES"
fi

# Check for common Puppet directories and files
PUPPET_PATHS=(
    "/etc/puppetlabs"
    "/opt/puppetlabs"
    "/var/log/puppetlabs"
    "/var/run/puppetlabs"
    "/etc/puppet"
)

FOUND_FILES=false
for path in "${PUPPET_PATHS[@]}"; do
    if [ -e "$path" ]; then
        FOUND_FILES=true
        echo -e "${BOLD_YELLOW}[!] Found existing Puppet files in: $path${NC}"
    fi
done

if [ "$FOUND_PACKAGES" = true ] || [ "$FOUND_FILES" = true ]; then
    echo -e "\n${BOLD_YELLOW}[!] Existing Puppet installation detected. Choose an option:${NC}"
    echo -e "1) Automatically remove existing packages and files (recommended)"
    echo -e "2) Exit script and clean up manually"
    echo -e "\n${BOLD_YELLOW}[!] Please select an option (1 or 2):${NC}"
    read -r CLEANUP_CHOICE

    case $CLEANUP_CHOICE in
        1)
            echo -e "${BOLD_YELLOW}[!] Removing existing Puppet installation...${NC}"
            if [ "$FOUND_PACKAGES" = true ]; then
                if ! apt remove --purge -y puppet* puppetserver; then
                    echo -e "${BOLD_RED}[✗] Failed to remove Puppet packages${NC}"
                    exit 1
                fi
            fi

            if [ "$FOUND_FILES" = true ]; then
                if ! rm -rf /etc/puppetlabs /opt/puppetlabs /var/log/puppetlabs /var/run/puppetlabs /etc/puppet; then
                    echo -e "${BOLD_RED}[✗] Failed to remove Puppet files. Please clean up manually and run again.${NC}"
                    echo -e "${BOLD_YELLOW} ┗━ sudo apt remove --purge puppet* puppetserver${NC}"
                    echo -e "${BOLD_YELLOW} ┗━ sudo rm -rf /etc/puppetlabs /opt/puppetlabs /var/log/puppetlabs /var/run/puppetlabs /etc/puppet${NC}"
                    exit 1
                fi
            fi
            echo -e "${BOLD_GREEN}[✓] Successfully removed existing Puppet installation${NC}"
            ;;
        2)
            echo -e "${BOLD_YELLOW}[!] Exiting script. Please clean up manually and run again.${NC}"
            echo -e "${BOLD_YELLOW} ┗━ sudo apt remove --purge puppet* puppetserver${NC}"
            echo -e "${BOLD_YELLOW} ┗━ sudo rm -rf /etc/puppetlabs /opt/puppetlabs /var/log/puppetlabs /var/run/puppetlabs /etc/puppet${NC}"
            exit 0
            ;;
        *)
            echo -e "${BOLD_RED}[✗] Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
fi

###### Install Puppet Server ######

echo -e "${BOLD_CYAN}[?] Will this device be the Puppet server? (y/N):${NC}"
read -r IS_PUPPET_SERVER

if [[ "$IS_PUPPET_SERVER" =~ ^[Yy]$ ]]; then
    echo -e "${BOLD_CYAN}[*] Checking for Puppet server...${NC}"
    if which puppet-server &> /dev/null; then
        echo -e "${BOLD_GREEN}[✓] Puppet server is already installed. No action required.${NC}"
    else
        echo -e "${BOLD_YELLOW}[!] Puppet server is not installed, installing now...${NC}"
        if ! APT_OUTPUT=$(apt install -y puppetserver 2>&1); then
            echo -e "${BOLD_RED}[✗] Puppet server installation failed with the following error:${NC}"
            echo -e "$APT_OUTPUT"
            exit 1
        fi

        # Verify installation
        if which puppetserver &> /dev/null; then
            echo -e "${BOLD_GREEN}[✓] Puppet server installation successful${NC}"

            # Install puppet modules
            echo -e "${BOLD_CYAN}[*] Installing Puppet modules...${NC}"


            # Start and enable the service
            echo -e "${BOLD_CYAN}[*] Starting Puppet server service...${NC}"
            systemctl start puppetserver
            systemctl enable puppetserver

            # Generate puppet server certificate
            echo -e "${BOLD_CYAN}[*] Generating Puppet server certificate...${NC}"
            puppet ca setup

            if systemctl is-active --quiet puppetserver; then
                echo -e "${BOLD_GREEN}[✓] Puppet server service started successfully${NC}"
            else
                echo -e "${BOLD_RED}[✗] Failed to start Puppet server service${NC}"
                echo -e "${BOLD_RED}Check logs with: journalctl -u puppetserver${NC}"
                exit 1
            fi
        else
            echo -e "${BOLD_RED}[✗] Puppet server installation failed. Package installed but puppetserver command not found.${NC}"
            echo -e "${BOLD_RED}Installation output:${NC}"
            echo -e "$APT_OUTPUT"
            exit 1
        fi
    fi
else
    echo -e "${BOLD_CYAN}[*] Puppet server will not be installed.${NC}"
fi

###### Install Puppet Agent ######

echo -e "${BOLD_CYAN}[*] Checking for Puppet agent...${NC}"
if which puppet &> /dev/null; then
  echo -e "${BOLD_GREEN}[✓] Puppet is already installed. No action required.${NC}"
else
  echo -e "${BOLD_YELLOW}[!] Puppet agent is not installed, installing now...${NC}"
  apt update
  apt install -y puppet-agent

  # Verify installation was successful
  if which puppet &> /dev/null; then
    echo -e "${BOLD_GREEN}[✓] Puppet installation successful${NC}"
  else
    echo -e "${BOLD_RED}[✗] Puppet installation failed. Please resolve the APT error and try again.${NC}"
    echo -e "${BOLD_RED} ┗━ Installation output:${NC}"
    echo -e "$APT_OUTPUT"
    exit 1
  fi
fi

# Set Puppet Server
if [[ "$IS_PUPPET_SERVER" =~ ^[Yy]$ ]]; then
    PUPPET_SERVER="localhost"
    echo -e "${BOLD_CYAN}[*] Automatically setting Puppet Server to localhost${NC}"
else
    read -p "${BOLD_YELLOW}[?] Enter the FQDN of the Puppet Server: ${NC}" PUPPET_SERVER
fi

ENVIRONMENT="production"
CERTNAME="$(hostname).orbit"

# Configure puppet.conf
echo -e "${BOLD_CYAN}[*] Configuring puppet.conf...${NC}"

cat <<EOF > /etc/puppetlabs/puppet/puppet.conf
[main]
certname = $CERTNAME
server = $PUPPET_SERVER
environment = $ENVIRONMENT
EOF

#Check if puppet is already running
if [ -f /opt/puppetlabs/puppet/cache/state/last_run_summary.yaml ]; then
  # Node has successfully applied at least one catalog
  echo -e "${BOLD_GREEN}[✓] Puppet has already run, skipping...${NC}"
else
  # Enable and start puppet agent
  echo -e "${BOLD_CYAN}[*] Enabling and starting puppet agent...${NC}"
  puppet resource service puppet ensure=running enable=true

  echo -e "${BOLD_CYAN}[*] Requesting Puppet cert...${NC}"
  puppet agent -t || true

  echo -e "${BOLD_PURPLE}[✓] Done. Verify the cert on $PUPPET_SERVER:${NC}"
  echo "  puppetserver ca list"
  echo -e "${BOLD_PURPLE}[+] Sign the cert with the following command:${NC}"
  echo "  puppetserver ca sign --certname $CERTNAME"
fi
