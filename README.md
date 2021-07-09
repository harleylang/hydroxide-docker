# Hydroxide Dockerfile

This repository provides an example Dockerfile configuration for [hydroxide](https://github.com/emersion/hydroxide).

Before submitting issues, please see the [hydroxide](https://github.com/emersion/hydroxide) docs and [Protomail](https://protonmail.com/support/) support pages for hydroxide and Protonmail specific matters.

All code samples assume the root of this repository as the starting working directory.

No guarantees explicit or implied are made regarding the warranty and security of this solution. It is one working example to get you started. If can improve any aspect of this example configuration, please submit an issue or send a pull request.

## Data storage

In general, these docker-related files automate the Protonmail login process via Hydroxide. To do this, your email and password are passed via environmental variables to the Docker runtime and your authentication data is stored in `~/.config/hydroxide/auth.json` inside the _hydroxide-docker_ volume.

WARNING: This running container and host file system will be holding your account login details. Access to this operating system should **never** be shared with someone you don't trust.

```JSON
auth.json {
  "myProtonLogon" : "base64encodedEncryptedAccessToken"
}
```

With the Dockerfile, other files on the host system  can access `auth.json` to send emails by querying `/opt/hydroxide-container/data-hydroxide/auth.json`. It is suggested that the Docker volume containing the secret rather be mounted to a secured location on the host, and that root and sudo access be limited.

## Setup

Below are some basic instructions to get you started.

### Directory prep

This is required for all methods of launching the container.

```Bash
# create folders where your hydroxide log file and auth tokens will live
mkdir /opt/hydroxide-container
mkdir /opt/hydroxide-container/data-hydroxide
chmod o+rwx /opt/hydroxide-container/data-hydroxide
```

### Dockerfile only

If you require a Dockerfile, see the [Dockerfile](/hydroxide) folder. If you are unfamiliar with Docker, here is some code to get you started. The `docker-compose` file is setup to share the auth.json file via volume sharing.

```Bash
# build the Dockerfile image
docker build -t hydroxide ./hydroxide

# Run interactive/attached
# Publish all ports
# Map our created directory
# Set our environment variables
# Chose our image
docker run -it \
--publish 1025:1025 --publish 1143:1143 --publish 8080:8080 \
--volume /opt/hydroxide-container/data-hydroxide:/home/hydroxide/.config/hydroxide \
--env EMAIL=${EMAIL} --env PASSWORD=${PASSWORD} \
hydroxide

# Clear out any stale credentials
rm -f /opt/hydroxide-container/data-hydroxide/auth.json
```

### Docker-compose

If you require a `docker-compose` file, see [docker-compose.yml](docker-compose.yml). If you are unfamiliar with docker-compose, here is some code to get you started.

```Bash
# Add your account credentials
vim .env

# spin container up
docker-compose stop && docker-compose up -d --build 
```

### Python test script

Regardless of whether you use `docker` or `docker-compose`, you can quickly test your setup with python in terminal like so:

```Bash

# you will need to edit the send_mail.py file, here I chose vim as my text editor, use what you prefer
vim send_mail.py

# while in vim, update:
# (1) the sender / receiver vars in the example() function to suit your needs, and
# (2) the addr variable if you are using docker-compose; in that case, set it to 'hydroxide'
# press the 'i' key to enter insert mode, make your changes, and press the 'esc' key when you are done
# type ':wq' (without brackets) to save your changes and exit 

# fire a test email
python3 send_mail.py

```
