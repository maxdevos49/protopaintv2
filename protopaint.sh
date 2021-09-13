#!/bin/bash
set -e

# Loads .env file if present
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi



# Build all of the images or the specified one
build() {
    docker-compose build "${@:1}"
}

# Remove the entire Docker environment
destroy() {
    read -p "This will delete containers, volumes and images. Are you sure? [y/N]: " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit; fi
    docker-compose down -v --rmi all --remove-orphans
}

# Stop and destroy all containers
down() {
    docker-compose down "${@:1}"
}

# Display and tail the logs of all containers or the specified one's
logs() {
    docker-compose logs -f "${@:1}"
}

# Restart the containers
restart() {
    stop && start
}

# Start the containers
start() {
    docker-compose up -d
}

# Stop the containers
stop() {
    docker-compose stop
}

# Generate a wildcard certificate
cert_generate() {
    rm -Rf .docker/nginx/certs/*.protopaint.*
    docker-compose run --rm nginx sh -c "cd /etc/nginx/certs && touch openssl.cnf && cat /etc/ssl/openssl.cnf > openssl.cnf && echo \"\" >> openssl.cnf && echo \"[ SAN ]\" >> openssl.cnf && echo \"subjectAltName=DNS.1:protopaint.local,DNS.2:*.protopaint.local\" >> openssl.cnf && openssl req -x509 -sha256 -nodes -newkey rsa:4096 -keyout protopaint.local.key -out protopaint.local.crt -days 3650 -subj \"/CN=*.protopaint.local\" -config openssl.cnf -extensions SAN && rm openssl.cnf"
}

# Install the certificate
# Does not work with wsl on linux unless the browser is also running through wsl
cert_install() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain .docker/nginx/certs/protopaint.local.crt
    else
        echo "Could not install the certificate on the host machine, please do it manually"
    fi
}

open_workspace() {
    code .
}

# Create .env from .env.example
env() {
    if [ ! -f .env ]; then
        cp .env.example .env
    fi

    # Loads .env variables
    export $(grep -v '^#' .env | xargs)
}

# Initialise the Docker environment and the application
init() {
    down && env && npm run init && build && cert_generate && cert_install && start;
}

# Update the Docker environment
update() {
    git pull &&
        build &&
        start
}

case "$1" in
build)
    build "${@:2}"
    ;;
compose)
    docker-compose "${@:2}"
    ;;
destroy)
    destroy
    ;;
down)
    down "${@:2}"
    ;;
logs)
    logs "${@:2}"
    ;;
code)
    open_workspace
    ;;
restart)
    restart
    ;;
start)
    start
    ;;
stop)
    stop
    ;;
init)
    init
    ;;
update)
    update
    ;;
cert)
    case "$2" in
    generate)
        cert_generate
        ;;
    install)
        cert_install
        ;;
    *)
        cat <<EOF

Certificate management commands.

Usage:
    paint cert <command>

Available commands:
    generate .................................. Generate a new certificate
    install ................................... Install the certificate

EOF
        ;;
    esac
    ;;
*)
    cat <<EOF

Command line interface for the Docker-based web development environment Protopaint.

Usage:
    paint <command> [options] [arguments]

Available commands:
    code ...................................... Opens the code workspace in vscode
    build [image] ............................. Build all of the images or the specified one
    destroy ................................... Remove the entire Docker environment
    cert ...................................... Certificate management commands
        generate .............................. Generate a new certificate
        install ............................... Install the certificate
    down [-v] ................................. Stop and destroy all containers
                                                Options:
                                                    -v .................... Destroy the volumes as well
    init ...................................... Initialise the Docker environment and the application
    logs [container] .......................... Display and tail the logs of all containers or the specified one's
    restart ................................... Restart the containers
    start ..................................... Start the containers
    stop ...................................... Stop the containers
    update .................................... Update project code from git

EOF
    exit 1
    ;;
esac