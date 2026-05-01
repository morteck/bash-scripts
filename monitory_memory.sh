#!/bin/bash

# Threshold for memory usage (percentage)
THRESHOLD=80

# Check current memory usage using 'free'
# We extract used and total memory to calculate the percentage
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

# Convert to integer for comparison
USAGE_INT=${MEMORY_USAGE%.*}

echo "Current Memory Usage: ${USAGE_INT}%"

if [ "$USAGE_INT" -gt "$THRESHOLD" ]; then
    MESSAGE="ALERT: Memory usage is at ${USAGE_INT}% (Threshold: ${THRESHOLD}%)"
    echo "$MESSAGE"
    
    # Optional: Log the alert to a file
    echo "$(date): $MESSAGE" >> ~/memory_alerts.log
    
    # Optional: Send a local system notification (requires libnotify-bin)
    # notify-send "Memory Alert" "$MESSAGE"
    
    # Optional: Send an email (requires mailutils/postfix configured)
    # echo "$MESSAGE" | mail -s "Memory Alert on $(hostname)" your-email@example.com
else
    echo "Memory usage is within safe limits."
fi
