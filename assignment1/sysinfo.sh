#!/bin/bash
# sysinfo.sh - prints basic system information and saves it to a dated file.

# Folder where this script lives (so the file is saved next to the script,
# even when cron runs it from another place)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/sysinfo-$(date +%F).txt"   # e.g. sysinfo-2026-11-26.txt

print_info() {
  echo "================================="
  echo "System Information"
  echo "================================="
  echo "Hostname: $(hostname)"
  echo "Date/Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Logged-in User: $(whoami)"
  echo
  echo "Disk Usage:"
  df -h /
  echo
  echo "Memory Usage:"
  free -h
  echo
  echo "Top 5 Processes by Memory:"
  ps -eo pid,user,%mem,comm --sort=-%mem | head -n 6
  echo
}

# Show on screen AND append to today's file
print_info | tee -a "$OUTPUT_FILE"
echo "Saved to: $OUTPUT_FILE"
