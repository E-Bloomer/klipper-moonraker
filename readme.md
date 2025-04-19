# Klipper-Moonraker Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/eddriver19/klipper-moonraker.svg)](https://hub.docker.com/r/eddriver19/klipper-moonraker)
[![License](https://img.shields.io/github/license/E-Bloomer/klipper-moonraker.svg)](https://github.com/E-Bloomer/klipper-moonraker/blob/main/LICENSE)

## Overview

This Docker container integrates Klipper firmware and the Moonraker API server into a single container allowing quick and easy deployment.  
Additionally also includes the optional Dynamic Macros extra by [3DCoded](https://github.com/3DCoded/DynamicMacros) which furtheer expands klipper functionality.  

## Features

- Combined Klipper and Moonraker in a single container
- Pre-configured default settings for quick deployment
- Automatic configuration file generation
- Added dynamic macro support
- Based on Linuxserver.io alpine base image
- Designed to work with frontend interfaces like Fluidd or Mainsail

## Prerequisites

- Docker installed on your host system
- A 3D printer with Klipper firmware installed

## Quick Start

### Using Docker Run

```bash
docker run -d \
  --name klipper-moonraker \
  -p 7125:7125 \
  -v /path/to/config:/config \
  -v /dev/serial/by-id/your-printer-id:/dev/printer \
  --device /dev/serial/by-id/your-printer-id:/dev/printer \
  eddriver19/klipper-moonraker:latest
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3'
services:
  klipper-moonraker:
    image: eddriver19/klipper-moonraker:latest
    container_name: klipper-moonraker
    restart: unless-stopped
    ports:
      - "7125:7125"
    volumes:
      - ./config:/config
    devices:
      - /dev/serial/by-id/your-printer-id:/dev/printer
```

Then run:

```bash
docker-compose up -d
```

## Configuration

The container automatically creates default configuration files if they don't exist.  

- `moonraker.conf`: Moonraker API server configuration
- `printer.cfg`: Klipper printer configuration
- And basic macros `*macros.cfg`

The default `printer.cfg` is a starting point only and ***will not run*** without editing, this is intentional as it needs to customised for each printer and improper settings could cause damage.  
You can customize these files by editing them in your mounted `/config` directory or through the editor in FLuidd or Mainsail.

### Default Configuration Path

Configuration files are stored in `/config/printer_data/config/` within the container.

## Building Locally

If you want to build the container locally:

```bash
git clone https://github.com/E-Bloomer/klipper-moonraker.git
cd klipper-moonraker
docker build -t klipper-moonraker .
```
To build without installing Dynamic Macros use:

```bash
docker build --build-arg INSTALL_DY_MAC=false -t klipper-moonraker .
```

## Integration with User Interfaces

This container is designed to work with:

- [Fluidd](https://github.com/fluidd-core/fluidd)
- [Mainsail](https://github.com/mainsail-crew/mainsail)

Follow their respective documentation for setup and integration with this Klipper-Moonraker container.

Docker compose examples:

## Fluidd

```yaml
  fluidd:
    container_name: fluidd
    image: ghcr.io/fluidd-core/fluidd:latest
    ports:
      - 2802:80
    restart: unless-stopped
```

## Mainsail

```yaml  
  mainsail:
    container_name: mainsail
    image: ghcr.io/mainsail-crew/mainsail:edge
    ports:
      - 2801:80
    volumes:
     - /path/to/config/config.json:/usr/share/nginx/html/config.json
    restart: unless-stopped
```

### The code above mounts a config file to start mainsail in remote mode:  
Contents of `config.json`
```json
{
    "instancesDB": "browser"
}
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TZ` | UTC | Timezone setting |
| `PUID` | 911 | User ID |
| `PGID` | 911 | Group ID |

### Viewing Logs

Log filse are stored at `/config/printer_data/logs`

```bash
docker logs klipper-moonraker
```

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.

## Acknowledgments

- [Klipper](https://github.com/Klipper3d/klipper) - The 3D printer firmware
- [Moonraker](https://github.com/Arksine/moonraker) - API Server for Klipper
- [DynamicMacros](https://github.com/3DCoded/DynamicMacros) - Dynamic Macros 
- [linuxserver.io](https://github.com/linuxserver) - Base image used