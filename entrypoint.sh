#!/bin/bash
set -e

BIN_SDK="/app/WizardGain"
IP_CHECKER_URL="https://raw.githubusercontent.com/techroy23/IP-Checker/refs/heads/main/app.sh"
ENABLE_IP_CHECKER="${ENABLE_IP_CHECKER:-false}"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

validate_email_input() {
  local EMAIL="${EMAIL:-}"
  local ARG="$1"

  if [ -z "$EMAIL" ] && [ $# -eq 0 ]; then
    log " >>> An2Kin >>> ERROR: EMAIL not provided (env or arg)."
    exit 1

  elif [ $# -gt 1 ]; then
    log " >>> An2Kin >>> ERROR: Too many positional arguments. Only one EMAIL argument is allowed."
    exit 1

  elif [ -n "$EMAIL" ] && [ -n "$ARG" ]; then
    log " >>> An2Kin >>> ERROR: Both EMAIL env and positional argument provided. Please use only one."
    exit 1

  elif [ -n "$EMAIL" ]; then
    local at_count
    at_count=$(printf "%s" "$EMAIL" | awk -F'@' '{print NF-1}')
    if [ "$at_count" -eq 1 ] && [[ "${EMAIL#*@}" == *.* ]]; then
      log " >>> An2Kin >>> INFO: Using EMAIL from environment: $EMAIL"
    else
      log " >>> An2Kin >>> ERROR: Invalid EMAIL format in environment: $EMAIL"
      exit 1
    fi

  elif [ -n "$ARG" ]; then
    local at_count
    at_count=$(printf "%s" "$ARG" | awk -F'@' '{print NF-1}')
    if [ "$at_count" -eq 1 ] && [[ "${ARG#*@}" == *.* ]]; then
      EMAIL="$ARG"
      log " >>> An2Kin >>> INFO: Using EMAIL from positional argument: $EMAIL"
    else
      log " >>> An2Kin >>> ERROR: Invalid EMAIL format in argument: $ARG"
      exit 1
    fi
  fi

  export EMAIL
}

setup_iptables() {
  log " >>> An2Kin >>> Setting up iptables and redsocks..."
  if ! iptables -t nat -L REDSOCKS -n >/dev/null 2>&1; then
    iptables -t nat -N REDSOCKS
  else
    iptables -t nat -F REDSOCKS
  fi
  iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
  iptables -t nat -A REDSOCKS -d $host -j RETURN
  iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345

  if ! iptables -t nat -C OUTPUT -p tcp -j REDSOCKS 2>/dev/null; then
    iptables -t nat -A OUTPUT -p tcp -j REDSOCKS
  fi
}

cleanup() {
  log " >>> An2Kin >>> Cleaning up iptables and redsocks..."
  iptables -t nat -F REDSOCKS 2>/dev/null || true
  iptables -t nat -D OUTPUT -p tcp -j REDSOCKS 2>/dev/null || true
  iptables -t nat -X REDSOCKS 2>/dev/null || true

  if [ -n "$REDSOCKS_PID" ]; then
    kill "$REDSOCKS_PID" 2>/dev/null || true
  fi
}

setup_proxy() {
  if [ -n "$PROXY" ]; then
    log " >>> An2Kin >>> External routing via proxy: $PROXY"

    host=$(echo "$PROXY" | cut -d: -f1)
    port=$(echo "$PROXY" | cut -d: -f2)

    cat >/etc/redsocks.conf <<EOF
base {
  log_debug = off;
  log_info = off;
  log = "stderr";
  daemon = off;
  redirector = iptables;
}

redsocks {
  local_ip = 0.0.0.0;
  local_port = 12345;
  ip = $host;
  port = $port;
  type = socks5;
}
EOF

    redsocks -c /etc/redsocks.conf >/dev/null 2>&1 &
    REDSOCKS_PID=$!

    setup_iptables
  else
    log " >>> An2Kin >>> Proxy not set, proceeding with direct connection"
  fi
}

check_ip() {
  if [ "$ENABLE_IP_CHECKER" = "true" ]; then
    log " >>> An2Kin >>> Checking current public IP..."
    if curl -fsSL "$IP_CHECKER_URL" | sh; then
      log " >>> An2Kin >>> IP checker script ran successfully"
    else
      log " >>> An2Kin >>> WARNING: Could not fetch or execute IP checker script"
    fi
  else
    log " >>> An2Kin >>> IP checker disabled (ENABLE_IP_CHECKER=$ENABLE_IP_CHECKER)"
  fi
}

main() {
  validate_email_input "$@"
  trap cleanup EXIT
  while true; do
      setup_proxy
      check_ip
      log " >>> An2Kin >>> Starting binary..."
      "$BIN_SDK" --email "$EMAIL" &
      PID=$!
      log " >>> An2Kin >>> APP PID is $PID"
      wait $PID
      log " >>> An2Kin >>> Process exited, restarting..."
      sleep 5
  done
}

main
