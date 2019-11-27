#!/bin/bash
# Install Docker, docker-compose, and add the current user to the docker group.

DOCKER_VERSION="get" # use "test" for latest (possibly unstable) version
DOCKER_COMPOSE_VERSION="1.25.0"

# Install docker
curl -fsSL https://$DOCKER_VERSION.docker.com | sh -

# Install docker-compose
sudo curl -fsSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $(whoami)
# Make docker the user's current group (so they don't have to logout and back in)
newgrp docker
