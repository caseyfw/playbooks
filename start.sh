#!/bin/bash

USER=${1:-$USER}
# AWS_ACCESS_KEY_ID=$([ -r ~/.aws/credentials ] && awk -F "=" '/aws_access_key_id/ {print $2}' ~/.aws/credentials | tr -d ' ' || echo $AWS_ACCESS_KEY_ID)
# AWS_SECRET_ACCESS_KEY=$([ -r ~/.aws/credentials ] && awk -F "=" '/aws_secret_access_key/ {print $2}' ~/.aws/credentials | tr -d ' ' || echo $AWS_SECRET_ACCESS_KEY)

# Ensure the ansible image exists
if ! docker images | grep -q 'caseyfw/ansible'; then
    echo "Building caseyfw/ansible image..."
    docker build -t caseyfw/ansible .
fi

echo "Running deployment container..."
docker run \
    --interactive \
    --tty \
    --rm \
    --name ua-deployment \
    --volume $(pwd):/code \
    --volume ${SSH_AUTH_SOCK}:/ssh-agent \
    --env SSH_AUTH_SOCK=/ssh-agent \
    --env USER=${USER} \
    --env UID=${UID} \
    --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
    --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    caseyfw/ansible \
    entry.sh
