#!/bin/ksh
# @(#) ZFS pulsechain snapshot cleanup

threshold_hours=48

now=$(date "+%s")
threshold=$(( threshold_hours * 3600 ))

zfs_list_output=$(zfs list -t snapshot -H)

while IFS= read -r line; do
    snapshot_date=$(echo "$line" | awk '{print $1}')
    snapshot_datetime=$(echo "$snapshot_date" | awk -F "_" '{print $2}')
    snapshot_year=${snapshot_datetime:0:4}
    snapshot_month=${snapshot_datetime:4:2}
    snapshot_day=${snapshot_datetime:6:2}
    snapshot_hour=${snapshot_datetime:9:2}
    snapshot_minute=${snapshot_datetime:11:2}
    snapshot_second=${snapshot_datetime:13:2}
    snapshot_timestamp=$(date -d "$snapshot_year-$snapshot_month-$snapshot_day $snapshot_hour:$snapshot_minute:$snapshot_second" "+%s")
    time_diff=$(( now - snapshot_timestamp ))

    if [ $time_diff -gt $threshold ]; then
    out=$(echo "$line" | awk '{print $1}')
        echo "Remove Snapshot: $out"
        zfs destroy "$out"
    fi
done <<< "$zfs_list_output"
