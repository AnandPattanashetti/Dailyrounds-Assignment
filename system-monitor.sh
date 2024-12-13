#!/bin/bash

# Default settings
INTERVAL=5
FORMAT="text"
OUTPUT_FILE="system_report.txt"

# Function to show usage instructions
usage() {
    echo "Usage: $0 [--interval SECONDS] [--format FORMAT] [--output FILE]"
    echo "    --interval    Monitoring interval in seconds (default: 5)"
    echo "    --format      Output format: text, JSON, or CSV (default: text)"
    echo "    --output      Output file to save the report (default: system_report.txt)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --interval)
            INTERVAL="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Validate input arguments
if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [ "$INTERVAL" -le 0 ]; then
    echo "Error: Interval must be a positive integer."
    exit 1
fi
if [[ "$FORMAT" != "text" && "$FORMAT" != "JSON" && "$FORMAT" != "CSV" ]]; then
    echo "Error: Format must be text, JSON, or CSV."
    exit 1
fi

# Function to collect system information
collect_system_info() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    MEM_INFO=$(free -m)
    TOTAL_MEM=$(echo "$MEM_INFO" | awk '/Mem:/ {print $2}')
    USED_MEM=$(echo "$MEM_INFO" | awk '/Mem:/ {print $3}')
    FREE_MEM=$(echo "$MEM_INFO" | awk '/Mem:/ {print $4}')
    DISK_INFO=$(df -h | awk 'NR==1 || /\/$/')
    TOP_PROCESSES=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -6)
}

# Function to trigger alerts
trigger_alerts() {
    if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
        echo "WARNING: CPU usage is above 80%!"
    fi
    MEM_USAGE_PERCENT=$(echo "scale=2; $USED_MEM * 100 / $TOTAL_MEM" | bc)
    if (( $(echo "$MEM_USAGE_PERCENT > 75" | bc -l) )); then
        echo "WARNING: Memory usage is above 75%! ($MEM_USAGE_PERCENT%)"
    fi
    echo "$DISK_INFO" | awk 'NR>1 && $5+0 > 90 {print "WARNING: Disk space usage above 90% on " $1}'
}

# Function to draw a visual graph
draw_graph() {
    local usage=$(printf "%.0f" "$1") # Convert to integer
    local max=50
    local filled=$((usage * max / 100))
    local empty=$((max - filled))
    printf "[%-${max}s]" "$(printf "#%.0s" $(seq 1 $filled))"
}

# Function to generate output in the requested format
generate_output() {
    case "$FORMAT" in
        text)
            {
                echo "System Performance Report"
                echo "-------------------------"
                echo "CPU Usage: $CPU_USAGE%"
                echo "Memory Usage: Total: ${TOTAL_MEM}MB, Used: ${USED_MEM}MB, Free: ${FREE_MEM}MB"
                echo "Disk Usage:"
                echo "$DISK_INFO"
                echo "Top 5 CPU-consuming processes:"
                echo "$TOP_PROCESSES"
            } > "$OUTPUT_FILE"
            ;;
        JSON)
            {
                echo "{"
                echo "  \"cpu_usage\": \"$CPU_USAGE\","
                echo "  \"memory\": {"
                echo "    \"total\": \"$TOTAL_MEM\","
                echo "    \"used\": \"$USED_MEM\","
                echo "    \"free\": \"$FREE_MEM\""
                echo "  },"
                echo "  \"disk_usage\": ["
                echo "$DISK_INFO" | awk 'NR>1 {printf "    {\"filesystem\": \"%s\", \"used\": \"%s\", \"available\": \"%s\", \"usage\": \"%s\"},\n", $1, $3, $4, $5}'
                echo "  ],"
                echo "  \"top_processes\": ["
                echo "$TOP_PROCESSES" | awk 'NR>1 {printf "    {\"pid\": \"%s\", \"name\": \"%s\", \"cpu\": \"%s\"},\n", $1, $2, $3}'
                echo "  ]"
                echo "}"
            } > "$OUTPUT_FILE"
            ;;
        CSV)
            {
                echo "CPU Usage,Memory Total,Memory Used,Memory Free"
                echo "$CPU_USAGE%,${TOTAL_MEM}MB,${USED_MEM}MB,${FREE_MEM}MB"
                echo "Filesystem,Used,Available,Usage"
                echo "$DISK_INFO" | awk 'NR>1 {print $1","$3","$4","$5}'
                echo "PID,Command,CPU%"
                echo "$TOP_PROCESSES" | awk 'NR>1 {print $1","$2","$3}'
            } > "$OUTPUT_FILE"
            ;;
    esac
    echo "Report saved to $OUTPUT_FILE"
}

# Continuous monitoring loop
while true; do
    collect_system_info
    clear
    echo "System Performance Monitoring"
    echo "-----------------------------"
    echo -n "CPU Usage: $CPU_USAGE% "
    draw_graph "$CPU_USAGE"
    echo
    MEM_USAGE_PERCENT=$(echo "scale=0; $USED_MEM * 100 / $TOTAL_MEM" | bc)
    echo -n "Memory Usage: $MEM_USAGE_PERCENT% "
    draw_graph "$MEM_USAGE_PERCENT"
    echo
    echo "Disk Usage:"
    echo "$DISK_INFO"
    echo "Top 5 CPU-consuming processes:"
    echo "$TOP_PROCESSES"
    trigger_alerts
    generate_output
    sleep "$INTERVAL"
done