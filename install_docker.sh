# Install docker
DOCKER_VERSION="test" # use "get" for stable version
curl -fsSL https://$DOCKER_VERSION.docker.com | sh -
# Install docker-compose
DOCKER_COMPOSE_VERSION="1.24.0"
sudo curl -fsSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
