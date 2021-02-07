#!/bin/sh -e

# If access token does not exist, attempt authentication
if [ ! -f ~/.config/hydroxide/auth.json ]; then

  if [ $# -ne 2 ] && [ $# -ne 3 ]; then
    printf "Incorrect argument count.\n"
    printf "Please provide:\n1) Username\n2) Password\n3) Two factor token [Optional]\n"
    exit 1
  fi

# If token length checks out or nothing was passed for it, attempt authentication for access token creation and storage.
  if [ ${#3} -eq 6 ] || [ -z ${3+x} ]; then
    printf "%s\n%s\n" "${2}" "${3}" | ./hydroxide auth "${1}"

    if [ $? -ne 0 ]; then
      printf "Authentication failed. Exiting.\n"
      exit 2
    fi

    printf "Authentication successful.\n"

  else
    printf "Two factor auth token is not the correct length. Exiting.\n"
    exit 3
  fi

fi

if [ "${DEBUG}" ]; then
  DBG="-debug"
fi

# MUST host on '0.0.0.0' for the ports to pass through to other containers
# From: https://github.com/docker/compose/issues/4799#issuecomment-623504144
if [ "${INTERPOD}" ]; then
  ARG="-smtp-host 0.0.0.0 -imap-host 0.0.0.0 -carddav-host 0.0.0.0"
fi

CMD="./hydroxide ${DBG} ${ARG} serve"
$CMD
