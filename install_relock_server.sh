#!/bin/bash

# Deployment script for pushing modified linien_server code
# to a Red Pitaya and rebooting the device.

set -e  # Stop on any error

echo "------------------------------------------------------------"
echo "    LINIEN SERVER DEPLOYMENT STARTED"
echo "------------------------------------------------------------"
echo ""

### ------------------------------
### CONFIGURATION (EDIT THIS)
### ------------------------------
RP_IP="rp-XXXXXX.local"        # Red Pitaya IP address EDIT THIS
### ------------------------------

LOCAL_DIR="./linien/server"    # Local modified server directory
RP_TARGET_DIR="/usr/local/lib/python3.5/dist-packages/linien/server"   # Remote install path

# 1. Verify that the local folder exists
if [ ! -d "$LOCAL_DIR" ]; then
    echo "ERROR: Local directory '$LOCAL_DIR' does not exist."
    exit 1
fi

echo "Local directory: $LOCAL_DIR"
echo "Remote directory: $RP_TARGET_DIR"
echo ""

# 2. Open one authenticated SSH connection and reuse it for both the copy
#    and the reboot, so you're only prompted for a password once, even
#    though no SSH key is set up on the Red Pitaya.
CONTROL_SOCKET="/tmp/linien_deploy_%h_%p_%r"
SSH_OPTS=(-o ControlMaster=auto -o ControlPath="$CONTROL_SOCKET" -o ControlPersist=60)

echo "Connecting to Red Pitaya ($RP_IP)... you may be asked for the root password."
ssh "${SSH_OPTS[@]}" root@"$RP_IP" "echo Connected." || {
    echo "ERROR: Could not connect to $RP_IP."
    exit 1
}
echo ""

# 3. Copy modified files to the Red Pitaya
echo "Copying modified linien_server files to Red Pitaya..."
scp -o ControlPath="$CONTROL_SOCKET" -r "$LOCAL_DIR"/* root@"$RP_IP":"$RP_TARGET_DIR"/
echo "Files copied successfully."
echo ""

# 4. Reboot Red Pitaya (reuses the same authenticated connection, no
#    second password prompt)
echo "Rebooting Red Pitaya..."
ssh -o ControlPath="$CONTROL_SOCKET" root@"$RP_IP" "reboot"

echo "Reboot command sent. SSH session will disconnect."
echo ""

# 5. Finished
echo "------------------------------------------------------------"
echo "    LINIEN SERVER DEPLOYMENT COMPLETE"
echo "------------------------------------------------------------"
echo ""