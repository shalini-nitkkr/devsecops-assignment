# Assignment 1 - Linux Shell Scripting and Git

Two small Bash scripts.

## Files
- `sysinfo.sh` - prints system information and saves it to `sysinfo-YYYY-MM-DD.txt`
- `log_report.sh` - reads a web log and prints a summary
- `access.log` - sample log for testing

## Requirements
Linux (or WSL on Windows, or macOS with `free` missing - use Linux/WSL), Bash.

## Make executable
```bash
chmod +x sysinfo.sh log_report.sh
```

## Run
```bash
./sysinfo.sh
./log_report.sh access.log
./log_report.sh              # shows usage message
./log_report.sh nope.log     # shows "file does not exist"
```

## Cron (runs sysinfo.sh every hour)
```bash
crontab -e
```
Add this line (change the path to your real folder):
```
0 * * * * /home/YOUR_USER/devsecops-assignment/assignment1/sysinfo.sh >/dev/null 2>&1
```

## Sample output - log_report.sh
```
=================================
Log Report: access.log
=================================
Total requests: 12
404 errors: 3

Top 3 IP addresses:
  5 requests - 192.168.1.10
  4 requests - 10.0.0.5
  2 requests - 172.16.0.8
```

## What each script does
- **sysinfo.sh** uses `hostname`, `date`, `whoami`, `df -h /`, `free -h` and `ps --sort=-%mem | head` to print the info, and `tee -a` to also save it in a file named with today's date.
- **log_report.sh** counts lines (`wc -l`) for total requests, uses `awk '$9 == 404'` to count 404 errors, and uses `awk | sort | uniq -c | sort -rn | head -3` to find the top 3 IPs.
