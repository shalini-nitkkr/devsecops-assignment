# DevSecOps Assignment

Two small tasks: (1) Linux shell scripts + Git, (2) a Dockerized Flask app with a GitHub Actions CI check.

## Folder structure
```
devsecops-assignment/
├── .github/workflows/build.yml   <- must be at the repo root for GitHub to see it
├── README.md
├── assignment1/
│   ├── sysinfo.sh
│   ├── log_report.sh
│   ├── access.log
│   └── README.md
└── assignment2/
    ├── app.py
    ├── requirements.txt
    ├── Dockerfile
    ├── .dockerignore
    └── README.md
```

---
# ASSIGNMENT 1 - Linux scripts and Git

## Requirements
Linux or WSL, Bash, Git.

## How to run
```bash
cd assignment1
chmod +x sysinfo.sh log_report.sh
./sysinfo.sh
./log_report.sh access.log
./log_report.sh            # usage message (bonus)
./log_report.sh missing.log  # missing-file message (bonus)
```

## What the scripts do
- `sysinfo.sh`: prints hostname, date/time, user, disk usage of `/`, memory usage and the top 5 processes by memory. Bonus: also saves the output to `sysinfo-YYYY-MM-DD.txt`.
- `log_report.sh`: prints total requests, number of 404 errors and the top 3 IP addresses from a log file.

## Sample output: log_report.sh
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

## Sample output: sysinfo.sh
```
=================================
System Information
=================================
Hostname: vm
Date/Time: 2026-11-26 08:08:25
Logged-in User: root

Disk Usage:
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda        252G  6.6G   10G  40% /

Memory Usage:
               total        used        free      shared  buff/cache   available
Mem:           3.9Gi       201Mi       3.8Gi        12Mi        79Mi       3.7Gi
Swap:             0B          0B          0B

Top 5 Processes by Memory:
  PID USER     %MEM COMMAND
   69 root      0.7 rclone-filestor
    1 root      0.1 process_api
  122 root      0.0 ps
  111 root      0.0 sysinfo.sh
   68 64321     0.0 8
```
(Your values will be different.)

## Cron: run sysinfo.sh every hour
```
0 * * * * /full/path/to/assignment1/sysinfo.sh >/dev/null 2>&1
```

## Git commands
```bash
git init
git add .
git commit -m "Add DevSecOps assignment"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```
Replace `YOUR_USERNAME` and `YOUR_REPO` with your real GitHub username and repo name.

---
# ASSIGNMENT 2 - Dockerized Flask app

## Flask app
`assignment2/app.py` has two routes: `/` returns "Hello from DevOps!" and `/health` returns `{"status": "ok"}`. It listens on port 5000.

## Dockerfile
See `assignment2/Dockerfile`. It uses `python:3.12-slim`, sets `WORKDIR /app`, installs `requirements.txt`, copies `app.py`, runs as a non-root user and starts `python app.py`.

## Build and run
```bash
cd assignment2
docker build -t myapp .
docker run -p 5000:5000 myapp
```
Port mapping is `host 5000 -> container 5000`.

## Health check (curl)
Open a second terminal:
```bash
curl localhost:5000/health
```

### Successful health-check output
I built and ran the container, then tested the health endpoint:
```
$ curl localhost:5000/health
{"status":"ok"}
```
shalini@Shalini:/mnt/c/Users/Shalini/Downloads/devsecops-assignment$ curl localhost:5000/health
{"status":"ok"}


## GitHub Actions
The workflow is `.github/workflows/build.yml` at the **repository root** (GitHub only reads workflows from there). On every push it checks out the code, builds the image (the job fails if the build fails), runs the container and calls `/health` (bonus).

## Problems in the Provided Dockerfile and Fixes

| Problem | Why it is wrong | Fix |
|---------|-----------------|-----|
| `FORM python:3.12-slim` | Typo. Docker has no `FORM` instruction, so the build fails immediately. | `FROM python:3.12-slim` |
| `pip install -r requirement.txt` | The file is called `requirements.txt` (with an "s"). pip cannot find it, so the build fails. | `pip install -r requirements.txt` |
| `docker run -p 5000:8080 myapp` | `-p HOST:CONTAINER`. The app listens on 5000 inside the container, but this sends traffic to container port 8080 where nothing listens, so the app can't be reached. | `docker run -p 5000:5000 myapp` |
| `COPY . .` before `pip install` (improvement) | Any code change re-runs the slow install step. | Copy `requirements.txt` first, install, then copy the code. |
| Runs as root (improvement) | Less secure. | Add a user and `USER appuser`. |

The line `app.run(host="0.0.0.0", ...)` in `app.py` is correct. It is needed so the app accepts connections from outside the container.

### Corrected Dockerfile
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
RUN useradd --create-home appuser
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]
```

## Optional bonus features done
- `.dockerignore`
- Container runs as non-root user (`appuser`)
- GitHub Actions step runs the container and checks `/health`
