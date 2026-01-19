# WizardGain Docker Image

A minimal Ubuntu Linux based Docker image that automatically downloads and runs the WizardGain.

## Links
| DockerHub | GitHub | Invite |
|----------|----------|----------|
| [![Docker Hub](https://img.shields.io/badge/ㅤ-View%20on%20Docker%20Hub-blue?logo=docker&style=for-the-badge)](https://hub.docker.com/r/techroy23/docker-wizardgain) | [![GitHub Repo](https://img.shields.io/badge/ㅤ-View%20on%20GitHub-black?logo=github&style=for-the-badge)](https://github.com/techroy23/Docker-WizardGain) | [![Invite Link](https://img.shields.io/badge/ㅤ-Join%20CastarSDK%20Now-brightgreen?logo=linktree&style=for-the-badge)](https://wizardgain.com?ref=HU91KM) |

## Features
- Lightweight Ubuntu Linux base image.
- Proxy support via Redsocks.

## Usage
- Before running the container, increase socket buffer sizes (required for high‑throughput streaming).
- To make these settings persistent across reboots, add them to /etc/sysctl.conf or a drop‑in file under /etc/sysctl.d/.

```bash
sudo sysctl -w net.core.rmem_max=8000000
sudo sysctl -w net.core.wmem_max=8000000
```

## Environment variables
| Variable | Requirement | Description |
|:--------:|:-----------:|:-----------:|
| `PROXY`  | Optional | External proxy endpoint in the form `host:port`. |
| via ENV<br />`-e EMAIL=XXX@YYY.ZZZ`<br />via ARG<br />`XXX@YYY.ZZZ`  | Required | Your email address. Container exits if not provided. |

## Run via ENV
```bash
docker run -d \
  --name=wizardgain \
  --cpus=0.25 --pull=always --restart=always \
  --log-driver=json-file --log-opt max-size=1m --log-opt max-file=1 \
  --cap-add=NET_ADMIN --cap-add=NET_RAW --sysctl net.ipv4.ip_forward=1 \
  -e PROXY=123.456.789.012:34567 \
  -e EMAIL='XXX@YYY.ZZZ'
  techroy23/docker-wizardgain:latest
```

## Run via ARG
```bash
docker run -d \
  --name=wizardgain \
  --cpus=0.25 --pull=always --restart=always \
  --log-driver=json-file --log-opt max-size=1m --log-opt max-file=1 \
  --cap-add=NET_ADMIN --cap-add=NET_RAW --sysctl net.ipv4.ip_forward=1 \
  -e PROXY=123.456.789.012:34567 \
  techroy23/docker-wizardgain:latest XXX@YYY.ZZZ
```

# Invite Link
### [https://wizardgain.com?ref=HU91KM](https://wizardgain.com?ref=HU91KM)
