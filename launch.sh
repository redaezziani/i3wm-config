#!/bin/bash

# Terminate ALL already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Detect the active network interface
DEFAULT_NETWORK_INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
export DEFAULT_NETWORK_INTERFACE

# Clean up old log files
rm -f /tmp/polybar.log

# Launch Polybar
echo "---" | tee -a /tmp/polybar.log
echo "Using network interface: $DEFAULT_NETWORK_INTERFACE" | tee -a /tmp/polybar.log

# Launch the main bar
polybar main 2>&1 | tee -a /tmp/polybar.log & disown

echo "Polybar launched with clean icon-based design..."