#!/usr/bin/env bash
# source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
source <(curl -fsSL https://raw.githubusercontent.com/freefos/ProxmoxVE/refs/head/flowfuse-device-agent/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: freefos
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://flowfuse.com/

APP="FlowFuse-Device"
var_tags="automation"
var_cpu="2"
var_ram="512"
var_disk="6"
var_os="debian"
var_version="12"
var_unprivileged="1"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  # Check if installation is present | -f for file, -d for folder
  if [[ ! -d /opt/flowfuse-device ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if [[ "$(node -v | cut -d 'v' -f 2)" == "18."* ]]; then
    if ! command -v npm >/dev/null 2>&1; then
      echo "Installing NPM..."
      $STD apt-get install -y npm
      echo "Installed NPM..."
    fi
  fi

  # Stopping Services
  msg_info "Stopping $APP"
  systemctl stop flowfuse-device
  msg_ok "Stopped $APP"

  # Creating Backup
  #msg_info "Creating Backup"
  #tar -czf "/opt/${APP}_backup_$(date +%F).tar.gz" [IMPORTANT_PATHS]
  #msg_ok "Backup Created"

  # Execute Update
  msg_info "Updating $APP LXC"
  $STD npm install -g @flowfuse/device-agent@latest
  msg_ok "Updated Successfully"

  # Starting Services
  msg_info "Starting $APP"
  systemctl start flowfuse-device
  msg_ok "Started $APP"
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:[PORT]${CL}"
