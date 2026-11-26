#!/bin/bash
# log_report.sh - summarises a web server access log.
# Usage: ./log_report.sh access.log

# Bonus: usage message if no file is given
if [ $# -lt 1 ]; then
  echo "Usage: $0 <log_file>"
  echo "Example: $0 access.log"
  exit 1
fi

LOG_FILE="$1"

# Bonus: handle missing file
if [ ! -f "$LOG_FILE" ]; then
  echo "Error: file '$LOG_FILE' does not exist."
  exit 1
fi

# One line in the log = one request
TOTAL=$(wc -l < "$LOG_FILE")
# Field 9 of a standard access log line is the HTTP status code
ERRORS_404=$(awk '$9 == 404' "$LOG_FILE" | wc -l)

echo "================================="
echo "Log Report: $LOG_FILE"
echo "================================="
echo "Total requests: $TOTAL"
echo "404 errors: $ERRORS_404"
echo
echo "Top 3 IP addresses:"
# Field 1 = IP address. Count each, sort biggest first, keep 3.
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -n 3 |
  awk '{printf "  %s requests - %s\n", $1, $2}'
