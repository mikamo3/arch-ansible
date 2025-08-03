# Container Role Analysis - Docker Output Issue

## Current Container Role Configuration
The container role (`roles/container/`) manages Docker installation and configuration with the following structure:

### Tasks (main.yml)
- Installs Docker engine and buildx plugin via pacman
- Optional Docker Compose standalone installation
- Optional container tools (buildah, skopeo)
- Enables and starts Docker service
- Adds main user to docker group

### Default Variables (defaults/main.yml)
```yaml
container:
  install: false          # Install container runtime and tools
  enable_service: true    # Enable and start Docker service
  add_user_to_group: true # Add main user to docker group
  tools:
    install_compose: false # Install Docker Compose standalone
    install_buildah: false # Install Buildah for advanced image building
    install_skopeo: false  # Install Skopeo for image management
```

## Issue Analysis
The user reports that Docker/Docker Compose is outputting logs twice. This is likely related to Docker daemon logging configuration, not the Ansible role itself.

## Potential Causes
1. **Docker daemon logging configuration**: Missing or incorrect `/etc/docker/daemon.json`
2. **Systemd journal configuration**: Docker logs appearing in both journald and Docker's internal logging
3. **Docker Compose logging driver**: Default logging driver configuration
4. **TTY/console output duplication**: Terminal/console configuration issues

## Missing Configuration
The current role does NOT configure:
- Docker daemon.json file for logging configuration
- Custom logging drivers
- Log rotation settings
- Docker Compose logging configuration