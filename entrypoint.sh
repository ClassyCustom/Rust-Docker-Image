#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`

# Update Rust Server
./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 +quit

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo ":/home/container$ ${MODIFIED_STARTUP}"

# OxideMod has been replaced with uMod
if [ ! -z "${OXIDE_URL}" ]; then
    echo "Updating Oxide..."
    curl -sSL "${OXIDE_URL}" >oxide.zip
    unzip -o -q oxide.zip
    rm oxide.zip
    echo "Disabling Oxide Sandbox"
    touch RustDedicated_Data/Managed/oxide.disable-sandbox
fi

# Fix for Rust not starting
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)

# Run the Server
node /wrapper.js "${MODIFIED_STARTUP}"