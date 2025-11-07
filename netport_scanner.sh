#!/usr/bin/env python3
"""
Service Watchdog
----------------
This Python script monitors remote hosts by periodically pinging them. If a host becomes unreachable,
it automatically connects via SSH and executes a defined restart command. Designed for self-hosted or lab environments where lightweight
service recovery automation is desired.

"""

import paramiko
import subprocess
import datetime
import time
import sys

# === Configuration ===
HOSTS = {
    "wikijs": {
        "ip": "192.168.1.10",
        "ssh_user": "your_user",
        "ssh_pass": "your_pass",
        "service_restart_cmd": "qm start 101"
    },
}

PING_TIMEOUT = 2
CHECK_INTERVAL = 300  # seconds
LOG_FILE = "service_watchdog.log"
# ======================


# === Logging ===
def log(message: str) -> None:
    """Write timestamped log messages to both console and file."""
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    entry = f"[{timestamp}] {message}"
    print(entry)
    with open(LOG_FILE, "a") as f:
        f.write(entry + "\n")


# === Connectivity Check ===
def ping(host: str) -> bool:
    """Ping a host and return True if reachable."""
    try:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", str(PING_TIMEOUT), host],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        return result.returncode == 0
    except Exception as e:
        log(f"Ping error for {host}: {e}")
        return False


# === SSH Recovery ===
def ssh_restart_service(host_info: dict) -> bool:
    """Attempt to SSH into host and execute the restart command."""
    ip = host_info["ip"]
    user = host_info["ssh_user"]
    password = host_info["ssh_pass"]
    cmd = host_info["service_restart_cmd"]

    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        log(f"Attempting SSH to {ip} to restart service...")

        client.connect(ip, username=user, password=password, timeout=10)
        stdin, stdout, stderr = client.exec_command(cmd)

        output = stdout.read().decode().strip()
        errors = stderr.read().decode().strip()
        client.close()

        log(f"Command output: {output}")
        if errors:
            log(f"Command errors: {errors}")
        return True
    except Exception as e:
        log(f"SSH failed for {ip}: {e}")
        return False


# === Main Execution Loop ===
def main() -> None:
    """Continuously monitor hosts and perform recovery actions if needed."""
    log("Starting Service Watchdog...")
    try:
        while True:
            for name, info in HOSTS.items():
                if not ping(info["ip"]):
                    log(f"⚠️ Host {name} ({info['ip']}) is DOWN! Attempting restart...")
                    success = ssh_restart_service(info)
                    if success:
                        log(f"✅ Restart command sent to {name}.")
                    else:
                        log(f"❌ Failed to restart {name} via SSH.")
                else:
                    log(f"🟢 {name} ({info['ip']}) is UP.")
            time.sleep(CHECK_INTERVAL)
    except KeyboardInterrupt:
        log("Service Watchdog stopped by user.")
        sys.exit(0)


# === Entry Point ===
if __name__ == "__main__":
    main()
