#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts
# Author: freefos
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://flowfuse.com/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  ca-certificates \
  gnupg
msg_ok "Installed Dependencies"

msg_info "Setting up Node.js Repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" >/etc/apt/sources.list.d/nodesource.list
msg_ok "Set up Node.js Repository"

msg_info "Installing Node.js"
$STD apt-get update
$STD apt-get install -y nodejs
msg_ok "Installed Node.js"

msg_info "Installing the FlowFuse Device Agent (Patience)"
$STD mkdir /opt/flowfuse-device
$STD chown -R "$USER" /opt/flowfuse-device
$STD npm install -g @flowfuse/device-agent
msg_ok "Installed the FlowFuse Device Agent"

msg_info "Creating Service"
curl -L https://raw.githubusercontent.com/FlowFuse/device-agent/refs/heads/main/service/flowfuse-device.service -o flowfuse-device.service
$STD mv flowfuse-device.service /etc/systemd/system/
$STD systemctl daemon-reload
$STD systemctl enable --now flowfuse-device
$STD systemctl start flowfuse-device
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
