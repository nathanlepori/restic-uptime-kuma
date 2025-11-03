#!/bin/bash

# Environment variables
if [ -z "$PUSH_BASE_URL" ]; then
    echo "Error: PUSH_BASE_URL environment variable is required"
    exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$RESTIC_PASSWORD" ]; then
    echo "Error: Required environment variables are missing"
    exit 1
fi

INTERVAL="${INTERVAL:-43200}"  # Default to 12 hours in seconds

check_backup_status() {
    # Get latest snapshot timestamp
    latest_snapshot=$(/usr/bin/restic -r s3:https://s3.swiss-backup04.infomaniak.com/restic snapshots --json latest | jq -r '.[].time')
    
    if [ -z "$latest_snapshot" ]; then
        echo "Error: Could not get latest snapshot time"
        return 1
    fi

    echo "Latest snapshot time: $latest_snapshot" >&2
    
    # Convert snapshot time to unix timestamp
    # Strip fractional seconds, change date and time separator from "T" to " " and strip timezone
    normalized=$(echo "$latest_snapshot" | sed -E 's/\.[0-9]+//; s/T/ /; s/([+-][0-9]{2}):([0-9]{2})$//')
    
    echo "Normalized snapshot time: $normalized" >&2

    # Parse to unix seconds
    snapshot_timestamp=$(date -d "$normalized" +%s)
    
    echo "Snapshot timestamp: $snapshot_timestamp" >&2


    current_timestamp=$(date +%s)
    
    # Calculate difference in hours
    diff_hours=$(( ($current_timestamp - $snapshot_timestamp) / 3600 ))
    
    echo "Difference in hours: $diff_hours" >&2
    if [ $diff_hours -lt 24 ]; then
        echo "Last backup is recent (< 24h old)"
        return 0
    else
        echo "Last backup is older than 24 hours"
        return 1
    fi
}

while true; do
    msg=$(check_backup_status)
    if [ $? -eq 0 ]; then
        status="up"
    else
        status="down"
    fi
    
    # Call the push URL with appropriate status    
    curl -G -s -o /dev/null \
        -d "status=${status}" \
        --data-urlencode "msg=${msg}" \
        -d "ping=" \
        "$PUSH_BASE_URL"

    echo "Pushed status: ${status} - ${msg}"
    
    sleep $INTERVAL
done
