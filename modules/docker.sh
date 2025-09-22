#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## Docker Container Management
# --------------------------------------------------------------------

# Basic Docker commands
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias db='docker build'
alias dr='docker run -it --rm'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dprune='docker system prune -f'

# Enhanced Docker functions
docker-clean() {
    echo "  Cleaning up Docker resources..."
    docker system prune -f --volumes
}

docker-bash() {
    if [ -z "$1" ]; then
        echo "Usage: docker-bash <container_id_or_name>"
        return 1
    fi
    docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh
}

docker-stats() {
    docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}
