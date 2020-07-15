#!/bin/bash

# TODO HYDROXIDEUSER and HYDROXIDEPASS must be set in docker-compose or Dockerfile for this to work

mkdir /json
export HYDROXIDEKEYRAW=$(echo $HYDROXIDEPASS | su - root -c "hydroxide auth $HYDROXIDEUSER")
IFS=":" read -ra HYDROXIDEKEYDELIMIT <<< "$HYDROXIDEKEYRAW"
export HYDROXIDEKEY="${HYDROXIDEKEYDELIMIT[2]:1}"
echo -e "{\x22user\x22: \x22$HYDROXIDEUSER\x22, \x22hash\x22: \x22$HYDROXIDEKEY\x22}" > /data/info.json

# MUST host on '0.0.0.0' for the ports to pass through to other containers
# From: https://github.com/docker/compose/issues/4799#issuecomment-623504144

hydroxide -smtp-host '0.0.0.0' smtp &> /data/output.log & 
tail -f /dev/null

