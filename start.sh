#!/bin/bash

# Make sure all the necessary environment variables are set
if [ -z "$TUNNEL_HOST" ]
then
  echo ERROR: \$TUNNEL_HOST is not set!
  exit 1
fi

if [ -z "$TUNNEL_PORT" ]
then
  echo ERROR: \$TUNNEL_PORT is not set!
  exit 1
fi

if [ -z "$TUNNEL_USER" ]
then
  echo ERROR: \$TUNNEL_USER is not set!
  exit 1
fi

if [ -z "$TUNNEL_SSH_KEY" ]
then
  echo ERROR: \$TUNNEL_SSH_KEY is not set!
  exit 1
fi


# Copy the ssh key into a local keyfile
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo -e "$TUNNEL_SSH_KEY" >> ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Allow setting of local target port but default to 80
DEVICE_PORT=${DEVICE_PORT:-80}

echo Connecting to $TUNNEL_HOST...
# The -N option on ssh should cause the connection to persist, but it doesn't seem
# to do so reliably (old ssh version on my target?)
# So using `sleep infinity` should hold the connection open. 
ssh -f \
  -o StrictHostKeyChecking=no \
  -o ServerAliveInterval=120 \
  -T -R $TUNNEL_PORT:localhost:$DEVICE_PORT $TUNNEL_USER@$TUNNEL_HOST \
  sleep infinity

if [ $? -eq 0 ]
then
  echo Connected.  Forwarding port $TUNNEL_PORT from $TUNNEL_HOST to local port $DEVICE_PORT.
else
  echo Unable to connect!
fi

sleep infinity
