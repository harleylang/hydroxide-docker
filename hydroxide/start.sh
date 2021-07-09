#!/bin/sh

if [ "${DEBUG}" ]; then
  DBG="-debug"
  echo $#
  echo $@
  echo $EMAIL
  echo $PASSWORD
fi

# If access token does not exist, attempt authentication
if [ ! -f ~/.config/hydroxide/auth.json ]; then

  if [ $# -ne 2 ]; then
    printf "Incorrect argument count.\n"
    printf "Please provide:\n1) Username\n2) Password\n"
    exit 1
  fi

    # Attempt authentication and token generation
    printf "%s\n%s\n" "${2}" | ./hydroxide auth "${1}"

    if [ $? -ne 0 ]; then
        printf "Authentication failed. Exiting.\n"
        exit 2
    fi

    printf "Authentication successful.\n"
fi

# MUST host on '0.0.0.0' for the ports to pass through to other containers
# From: https://github.com/docker/compose/issues/4799#issuecomment-623504144
if [ "${INTERPOD}" ]; then
  ARG="-smtp-host 0.0.0.0 -imap-host 0.0.0.0 -carddav-host 0.0.0.0"
fi

CMD="./hydroxide ${DBG} ${ARG} serve"
$CMD
