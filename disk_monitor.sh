# A Bash script that monitors disk usage across all mounted partitions and logs system metrics
# (uptime, load averages, and disk utilization) in NDJSON format at /var/log/disk_usage_monitor.ndjson.
# If any partition exceeds the defined usage threshold (default: 75%), it automatically sends an
# email alert with system details. Designed for cron execution, it provides a lightweight, dependency-free
# monitoring solution for Linux servers.

#!/bin/bash

# === Configuration ===
THRESHOLD=75
TO="your_email@example.com"
SUBJECT="Disk Usage Alert on $(hostname)"
LOGFILE="/var/log/disk_usage_monitor.ndjson"   # Newline-delimited JSON (NDJSON)
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/your_webhook_id/your_webhook_token"

# === System Info ===
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)
UPTIME=$(uptime -p | sed 's/^up //')
read LOAD1 LOAD5 LOAD15 _ < /proc/loadavg

# === Variables ===
EMAIL_BODY=""
DISCORD_BODY=""
DISK_ENTRIES=()

# === Helper: safe logging ===
log_json() {
    echo "$1" >> "$LOGFILE" || echo "Failed to write to log file: $LOGFILE" >&2
}

# === Helper: JSON escape (for safety) ===
json_escape() {
    echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# === Gather disk usage ===
while IFS= read -r line; do
    USAGE=$(echo "$line" | awk '{print $5}' | tr -d '%')
    MOUNT=$(echo "$line" | awk '{print $6}')

    # Append disk entry to array
    DISK_ENTRIES+=("{\"mount_point\":\"$(json_escape "$MOUNT")\",\"usage_percent\":$USAGE}")

    # Trigger alert if usage exceeds threshold
    if (( USAGE >= THRESHOLD )); then
        ALERT_LINE="⚠️ $MOUNT is at ${USAGE}%"
        EMAIL_BODY+="$ALERT_LINE\n"
        DISCORD_BODY+="$ALERT_LINE\n"
    fi
done < <(df -hP | grep "^/dev/")

# === Construct JSON log entry ===
DISK_JSON=$(IFS=,; echo "${DISK_ENTRIES[*]}")

LOG_ENTRY=$(cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "hostname": "$HOSTNAME",
  "uptime": "$UPTIME",
  "load_avg": {"1min": $LOAD1, "5min": $LOAD5, "15min": $LOAD15},
  "disk_usage": [ $DISK_JSON ]
}
EOF
)

# === Append to NDJSON log ===
log_json "$LOG_ENTRY"

# === Send alerts if threshold exceeded ===
if [ -n "$EMAIL_BODY" ]; then
    echo -e "$EMAIL_BODY\n\nUptime: $UPTIME\nLoad Avg: $LOAD1, $LOAD5, $LOAD15" \
        | mail -s "$SUBJECT" "$TO"

    # Discord webhook send
    curl -fsSL -H "Content-Type: application/json" \
         -X POST \
         -d "{
               \"username\": \"Disk Monitor\",
               \"content\": \"**Disk Alert - $HOSTNAME**\n$DISCORD_BODY\n\n🕒 Uptime: $UPTIME\n🔥 Load: $LOAD1, $LOAD5, $LOAD15\"
             }" \
         "$DISCORD_WEBHOOK_URL" \
         >/dev/null 2>&1 || echo "Failed to send Discord alert" >&2
fi
