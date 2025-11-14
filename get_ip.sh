## Features
- **Prints out every IPv4 address on your system.**
- **Lists each network interface (eth0, wlan0, lo, etc.) with its corresponding IP.**
- **Active Network Interface — Displays your primary IP address (non-localhost).**

---

#!/bin/bash

echo "=== All IP Addresses ==="
ifconfig | grep -E "inet " | awk '{print $2}'

echo ""
echo "=== IP Addresses by Interface ==="
for interface in $(ifconfig | grep -E "^[a-zA-Z0-9]+" -o | sort -u); do
    ip=$(ifconfig "$interface" 2>/dev/null | grep -E "inet " | awk '{print $2}' | head -1)
    if [ -n "$ip" ]; then
        echo "$interface: $ip"
    fi
done

echo ""
echo "=== Active Network Interface (Primary IP) ==="
ifconfig | grep -E
